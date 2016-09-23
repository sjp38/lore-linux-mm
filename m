Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3796B027B
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 22:33:42 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e1so7263683itb.1
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:33:42 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id o14si1277338itb.13.2016.09.22.19.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 19:33:41 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id hm5so35123832pac.0
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 19:33:41 -0700 (PDT)
Date: Thu, 22 Sep 2016 19:33:34 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] shmem: fix tmpfs to handle the huge= option
 properly
In-Reply-To: <8737ksw69p.fsf@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.11.1609221904020.19987@eggly.anvils>
References: <1473459863-11287-1-git-send-email-toshi.kani@hpe.com> <1473459863-11287-2-git-send-email-toshi.kani@hpe.com> <8737ksw69p.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Toshi Kani <toshi.kani@hpe.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, dan.j.williams@intel.com, mawilcox@microsoft.com, hughd@google.com, kirill.shutemov@linux.intel.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 22 Sep 2016, Aneesh Kumar K.V wrote:
> Toshi Kani <toshi.kani@hpe.com> writes:
> 
> > shmem_get_unmapped_area() checks SHMEM_SB(sb)->huge incorrectly,
> > which leads to a reversed effect of "huge=" mount option.
> >
> > Fix the check in shmem_get_unmapped_area().
> >
> > Note, the default value of SHMEM_SB(sb)->huge remains as
> > SHMEM_HUGE_NEVER.  User will need to specify "huge=" option to
> > enable huge page mappings.
> >
> 
> Any update on getting this merged ?
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Yikes, how did we ever not notice this?  Very embarrassing.

Huge thank you to Hillf for spotting it (only now do I rediscover
your June mail: I'm sorry, my attention has been fully elsewhere).

Big thank you to Toshi for sending the patch,
and to Aneesh for now sounding the alarm.

The only reassurance is that at least all the rest of it has
been under test for the last few months, via the SHMEM_HUGE_FORCE
override.  So it's not as if none of the code has been tested,
but I am still mystified why it hasn't been obvious without.

To the patch,
Acked-by: Hugh Dickins <hughd@google.com>
but I wish I could dream up a more emphatic tag.

Andrew, please please grab this and send it in!

Thank you,
Hugh

> 
> > Reported-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> > Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Hugh Dickins <hughd@google.com>
> > ---
> >  mm/shmem.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index fd8b2b5..aec5b49 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1980,7 +1980,7 @@ unsigned long shmem_get_unmapped_area(struct file *file,
> >  				return addr;
> >  			sb = shm_mnt->mnt_sb;
> >  		}
> > -		if (SHMEM_SB(sb)->huge != SHMEM_HUGE_NEVER)
> > +		if (SHMEM_SB(sb)->huge == SHMEM_HUGE_NEVER)
> >  			return addr;
> >  	}
> >  
> >
> > --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
