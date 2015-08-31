Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9216B0254
	for <linux-mm@kvack.org>; Mon, 31 Aug 2015 05:12:40 -0400 (EDT)
Received: by wicpl12 with SMTP id pl12so21418916wic.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:12:40 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id b4si19877913wic.119.2015.08.31.02.12.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 02:12:39 -0700 (PDT)
Received: by widfa3 with SMTP id fa3so17585768wid.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 02:12:38 -0700 (PDT)
Date: Mon, 31 Aug 2015 11:12:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150831091236.GC29723@dhcp22.suse.cz>
References: <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
 <20150821163033.GA4600@Sligo.logfs.org>
 <20150824085127.GB17078@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
 <20150826063813.GA25196@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com>
 <20150827064817.GB14367@dhcp22.suse.cz>
 <20150827172351.GA29092@Sligo.logfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150827172351.GA29092@Sligo.logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu 27-08-15 10:23:51, Jorn Engel wrote:
> On Thu, Aug 27, 2015 at 08:48:18AM +0200, Michal Hocko wrote:
> > 
> > > On x86, HUGE_MAX_HSTATE == 2.  I don't consider that to be expensive.
> > > 
> > > If you are concerned about the memory allocation of struct hugetlb_usage, 
> > > it could easily be embedded directly in struct mm_struct.
> > 
> > Yes I am concerned about that and
> > 9 files changed, 112 insertions(+), 1 deletion(-)
> > for something that is even not clear to be really required. And I still
> > haven't heard any strong usecase to justify it.
> > 
> > Can we go with the single and much simpler cumulative number first and
> > only add the break down list if it is _really_ required? We can even
> > document that the future version of /proc/<pid>/status might add an
> > additional information to prepare all the parsers to be more careful.
> 
> I don't care much which way we decide.  But I find your reasoning a bit
> worrying.  If someone asks for a by-size breakup of hugepages in a few
> years, you might have existing binaries that depend on the _absence_ of
> those extra characters on the line.
> 
> Compare:
>   HugetlbPages:      18432 kB
>   HugetlbPages:    1069056 kB (1*1048576kB 10*2048kB)
> 
> Once someone has written a script that greps for 'HugetlbPages:.*kB$',
> you have lost the option of adding anything else to the line. 

If you think that an explicit note in the documentation is
not sufficient then I believe we can still handle it backward
compatible. Like separate entries for each existing hugetlb page:
HugetlbPages:	     1069056 kB
Hugetlb2MPages:	     20480 kB
Hugetlb1GPages:	     1048576 kB

or something similar. I would even argue this would be slightly easier
to parse. So it is not like we would be locked into anything.

> You have
> created yet another ABI compatibility headache today in order to save
> 112 lines of code.
> 
> That may be a worthwhile tradeoff, I don't know.  But at least I realize
> there is a cost, while you seem to ignore that component.  There is
> value in not painting yourself into a corner.

My primary point was that we are adding a code for a feature nobody
actually asked for just because somebody might ask for it in future.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
