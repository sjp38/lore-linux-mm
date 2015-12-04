Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 915AE6B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 03:52:29 -0500 (EST)
Received: by wmww144 with SMTP id w144so52857067wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:52:29 -0800 (PST)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 14si4408374wmq.78.2015.12.04.00.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 00:52:28 -0800 (PST)
Received: by wmww144 with SMTP id w144so52856619wmw.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:52:28 -0800 (PST)
Date: Fri, 4 Dec 2015 09:52:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: memcg uncharge page counter mismatch
Message-ID: <20151204085226.GB10021@dhcp22.suse.cz>
References: <20151202101643.GC25284@dhcp22.suse.cz>
 <20151203013404.GA30779@bbox>
 <20151203021006.GA31041@bbox>
 <20151203085451.GC9264@dhcp22.suse.cz>
 <20151203125950.GA1428@bbox>
 <20151203133719.GF9264@dhcp22.suse.cz>
 <20151203134326.GG9264@dhcp22.suse.cz>
 <20151203145850.GH9264@dhcp22.suse.cz>
 <20151203154729.GI9264@dhcp22.suse.cz>
 <20151204053515.GA5174@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151204053515.GA5174@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 04-12-15 14:35:15, Minchan Kim wrote:
> On Thu, Dec 03, 2015 at 04:47:29PM +0100, Michal Hocko wrote:
> > On Thu 03-12-15 15:58:50, Michal Hocko wrote:
> > [....]
> > > Warning, this looks ugly as hell.
> > 
> > I was thinking about it some more and it seems that we should rather not
> > bother with partial thp at all and keep it in the original memcg
> > instead. It is way much less code and I do not think this will be too
> > disruptive. Somebody should be holding the thp head, right?
> > 
> > Minchan, does this fix the issue you are seeing.
> 
> This patch solves the issue but not sure it's right approach.
> I think it could make regression that in old, we could charge
> a THP page but we can't now.

The page would still get charged when allocated. It just wouldn't get
moved when mapped only partially. IIUC there will be still somebody
mapping the THP head via pmd, right? That process will move the page to
the new memcg when moved. Or is it possible that we will end up only
with pte mapped THP from all processes? Kirill?

If not then I think it is reasonable to expect that partially mapped THP
is not moved during task migration. I will post an official patch after
Kirill confirms my understanding.

Anyway thanks for the testing and pointing me to right direction
Minchan!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
