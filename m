Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 651DC6B025A
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 04:16:43 -0500 (EST)
Received: by pacej9 with SMTP id ej9so84448877pac.2
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 01:16:43 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id p7si18288128pfi.26.2015.12.04.01.16.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 01:16:42 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so84232872pac.3
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 01:16:42 -0800 (PST)
Date: Fri, 4 Dec 2015 18:16:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151204091634.GB5174@blaptop>
References: <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
 <20151203145850.GH9264@dhcp22.suse.cz>
 <20151203154729.GI9264@dhcp22.suse.cz>
 <20151204053515.GA5174@blaptop>
 <20151204085226.GB10021@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151204085226.GB10021@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 04, 2015 at 09:52:27AM +0100, Michal Hocko wrote:
> On Fri 04-12-15 14:35:15, Minchan Kim wrote:
> > On Thu, Dec 03, 2015 at 04:47:29PM +0100, Michal Hocko wrote:
> > > On Thu 03-12-15 15:58:50, Michal Hocko wrote:
> > > [....]
> > > > Warning, this looks ugly as hell.
> > > 
> > > I was thinking about it some more and it seems that we should rather not
> > > bother with partial thp at all and keep it in the original memcg
> > > instead. It is way much less code and I do not think this will be too
> > > disruptive. Somebody should be holding the thp head, right?
> > > 
> > > Minchan, does this fix the issue you are seeing.
> > 
> > This patch solves the issue but not sure it's right approach.
> > I think it could make regression that in old, we could charge
> > a THP page but we can't now.
> 
> The page would still get charged when allocated. It just wouldn't get
> moved when mapped only partially. IIUC there will be still somebody
> mapping the THP head via pmd, right? That process will move the page to

If I read code correctly, No. The split_huge_pmd splits just pmd,
not page itself. IOW, it could be possible !pmd_trans_huge(pmd) &&
PageTransHuge although there is only process owns the page.

> the new memcg when moved. Or is it possible that we will end up only
> with pte mapped THP from all processes? Kirill?

I'm not Kirill but I think it's possible.
If so, a thing we can use is page_mapcount(page) == 1. With that,
it could gaurantee only a process owns the page so charge 512 instead of 1?

> 
> If not then I think it is reasonable to expect that partially mapped THP
> is not moved during task migration. I will post an official patch after
> Kirill confirms my understanding.
> 
> Anyway thanks for the testing and pointing me to right direction
> Minchan!

Thanks for the quick patch and feedback, Michal.

> 
> -- 
> Michal Hocko
> SUSE Labs

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
