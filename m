Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 305976B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 18:45:58 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id e68so1599200oih.21
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 15:45:58 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id x12si1126629otg.28.2017.10.25.15.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Oct 2017 15:45:53 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] Hugetlb pages rss accounting is incorrect in
 /proc/<pid>/smaps
Date: Wed, 25 Oct 2017 22:45:10 +0000
Message-ID: <20171025224508.GA18691@hori1.linux.bs1.fc.nec.co.jp>
References: <1508889368-14489-1-git-send-email-prakash.sangappa@oracle.com>
 <20171025065527.wmii7ce5y5i4exx5@dhcp22.suse.cz>
In-Reply-To: <20171025065527.wmii7ce5y5i4exx5@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B2CA56BE5818424693BACB162DD983A3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Prakash Sangappa <prakash.sangappa@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "dancol@google.com" <dancol@google.com>

On Wed, Oct 25, 2017 at 08:55:27AM +0200, Michal Hocko wrote:
> [CCing Naoya]
>=20
> On Tue 24-10-17 16:56:08, Prakash Sangappa wrote:
> > Resident set size(Rss) accounting of hugetlb pages is not done
> > currently in /proc/<pid>/smaps. The pmap command reads rss from
> > this file and so it shows Rss to be 0 in pmap -x output for
> > hugetlb mapped vmas. This patch fixes it.
>=20
> We do not account in rss because we do have a dedicated counters
> depending on whether the hugetlb page is mapped privately or it is
> shared. The reason this is not in RSS IIRC is that a large unexpected
> RSS from hugetlb pages might confuse system monitors.

Yes, that was the intention of separate counters for hugetlb.

> This is one of
> those backward compatibility issues when you start accounting something
> too late.

So new monitoring applications are supposed to check the new counters
to track hugetlb usages.

Thanks,
Naoya Horiguchi


>=20
> > Signed-off-by: Prakash Sangappa <prakash.sangappa@oracle.com>
> > ---
> >  fs/proc/task_mmu.c | 1 +
> >  1 file changed, 1 insertion(+)
> >=20
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 5589b4b..c7e1048 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -724,6 +724,7 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned=
 long hmask,
> >  			mss->shared_hugetlb +=3D huge_page_size(hstate_vma(vma));
> >  		else
> >  			mss->private_hugetlb +=3D huge_page_size(hstate_vma(vma));
> > +		mss->resident +=3D huge_page_size(hstate_vma(vma));
> >  	}
> >  	return 0;
> >  }
> > --=20
> > 2.7.4
> >=20
>=20
> --=20
> Michal Hocko
> SUSE Labs
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
