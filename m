Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5173D831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 22:50:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d127so48821352pga.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 19:50:49 -0700 (PDT)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id h88si6915341pfa.303.2017.05.18.19.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 19:50:48 -0700 (PDT)
Received: by mail-pg0-x22c.google.com with SMTP id u187so31403414pgb.0
        for <linux-mm@kvack.org>; Thu, 18 May 2017 19:50:48 -0700 (PDT)
From: Junaid Shahid <junaids@google.com>
Subject: Re: [PATCH] dm ioctl: Restore __GFP_HIGH in copy_params()
Date: Thu, 18 May 2017 19:50:46 -0700
Message-ID: <1508444.i5EqlA1upv@js-desktop.svl.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
References: <20170518185040.108293-1-junaids@google.com> <20170518190406.GB2330@dhcp22.suse.cz> <alpine.DEB.2.10.1705181338090.132717@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, andreslc@google.com, gthelen@google.com, mpatocka@redhat.com, vbabka@suse.cz, linux-kernel@vger.kernel.org

(Adding back the correct linux-mm email address and also adding linux-kernel.)

On Thursday, May 18, 2017 01:41:33 PM David Rientjes wrote:
> On Thu, 18 May 2017, Michal Hocko wrote:
> 
> > On Thu 18-05-17 11:50:40, Junaid Shahid wrote:
> > > d224e9381897 (drivers/md/dm-ioctl.c: use kvmalloc rather than opencoded
> > > variant) left out the __GFP_HIGH flag when converting from __vmalloc to
> > > kvmalloc. This can cause the IOCTL to fail in some low memory situations
> > > where it wouldn't have failed earlier. This patch adds it back to avoid
> > > any potential regression.
> > 
> > The code previously used __GFP_HIGH only for the vmalloc fallback and
> > that doesn't make that much sense with the current implementation
> > because vmalloc does order-0 pages and those do not really fail and the
> > oom killer is invoked to free memory.
> > 
> 
> Order-0 pages certainly do fail, there is not an infinite amount of memory 
> nor is there a specific exemption to allow order-0 memory to be alloctable 
> below watermarks without this gfp flag.  OOM kill is the last thing we 
> want for these allocations since they are very temporary.
> 
> > There is no reason to access memory reserves from this context.
> > 
> 
> Let's ask Mikulas, who changed this from PF_MEMALLOC to __GFP_HIGH, 
> assuming there was a reason to do it in the first place in two different 
> ways.
> 
> This decision is up to the device mapper maintainers.
> 
> > > Signed-off-by: Junaid Shahid <junaids@google.com>
> > > ---
> > >  drivers/md/dm-ioctl.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/drivers/md/dm-ioctl.c b/drivers/md/dm-ioctl.c
> > > index 0555b4410e05..bacad7637a56 100644
> > > --- a/drivers/md/dm-ioctl.c
> > > +++ b/drivers/md/dm-ioctl.c
> > > @@ -1715,7 +1715,7 @@ static int copy_params(struct dm_ioctl __user *user, struct dm_ioctl *param_kern
> > >  	 */
> > >  	dmi = NULL;
> > >  	noio_flag = memalloc_noio_save();
> > > -	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL);
> > > +	dmi = kvmalloc(param_kernel->data_size, GFP_KERNEL | __GFP_HIGH);
> > >  	memalloc_noio_restore(noio_flag);
> > >  
> > >  	if (!dmi) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
