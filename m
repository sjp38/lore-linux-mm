Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C324B6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:23:55 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so32294143pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:23:55 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id n9si4852351pdr.22.2015.08.27.10.23.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 10:23:54 -0700 (PDT)
Received: by pabzx8 with SMTP id zx8so32293631pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 10:23:54 -0700 (PDT)
Date: Thu, 27 Aug 2015 10:23:51 -0700
From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150827172351.GA29092@Sligo.logfs.org>
References: <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
 <20150821163033.GA4600@Sligo.logfs.org>
 <20150824085127.GB17078@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
 <20150826063813.GA25196@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com>
 <20150827064817.GB14367@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150827064817.GB14367@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Aug 27, 2015 at 08:48:18AM +0200, Michal Hocko wrote:
> 
> > On x86, HUGE_MAX_HSTATE == 2.  I don't consider that to be expensive.
> > 
> > If you are concerned about the memory allocation of struct hugetlb_usage, 
> > it could easily be embedded directly in struct mm_struct.
> 
> Yes I am concerned about that and
> 9 files changed, 112 insertions(+), 1 deletion(-)
> for something that is even not clear to be really required. And I still
> haven't heard any strong usecase to justify it.
> 
> Can we go with the single and much simpler cumulative number first and
> only add the break down list if it is _really_ required? We can even
> document that the future version of /proc/<pid>/status might add an
> additional information to prepare all the parsers to be more careful.

I don't care much which way we decide.  But I find your reasoning a bit
worrying.  If someone asks for a by-size breakup of hugepages in a few
years, you might have existing binaries that depend on the _absence_ of
those extra characters on the line.

Compare:
  HugetlbPages:      18432 kB
  HugetlbPages:    1069056 kB (1*1048576kB 10*2048kB)

Once someone has written a script that greps for 'HugetlbPages:.*kB$',
you have lost the option of adding anything else to the line.  You have
created yet another ABI compatibility headache today in order to save
112 lines of code.

That may be a worthwhile tradeoff, I don't know.  But at least I realize
there is a cost, while you seem to ignore that component.  There is
value in not painting yourself into a corner.

Jorn

--
A quarrel is quickly settled when deserted by one party; there is
no battle unless there be two.
-- Seneca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
