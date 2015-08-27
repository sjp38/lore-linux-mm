Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 146976B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 02:48:23 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so34829897wid.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 23:48:22 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id w2si14627026wiy.40.2015.08.26.23.48.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 23:48:21 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so34829232wid.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 23:48:20 -0700 (PDT)
Date: Thu, 27 Aug 2015 08:48:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150827064817.GB14367@dhcp22.suse.cz>
References: <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
 <20150821163033.GA4600@Sligo.logfs.org>
 <20150824085127.GB17078@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
 <20150826063813.GA25196@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1508261451540.19139@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed 26-08-15 15:02:49, David Rientjes wrote:
> On Wed, 26 Aug 2015, Michal Hocko wrote:
> 
> > I thought the purpose was to give the amount of hugetlb based
> > resident memory.
> 
> Persistent hugetlb memory is always resident, the goal is to show what is 
> currently mapped.
> 
> > At least this is what Jorn was asking for AFAIU.
> > /proc/<pid>/status should be as lightweight as possible. The current
> > implementation is quite heavy as already pointed out. So I am really
> > curious whether this is _really_ needed. I haven't heard about a real
> > usecase except for top displaying HRss which doesn't need the break
> > down values. You have brought that up already
> > http://marc.info/?l=linux-mm&m=143941143109335&w=2 and nobody actually
> > asked for it. "I do not mind having it" is not an argument for inclusion
> > especially when the implementation is more costly and touches hot paths.
> > 
> 
> It iterates over HUGE_MAX_HSTATE and reads atomic usage counters twice.  

I am not worried about /proc/<pid>/status read path. That one is indeed
trivial.

> On x86, HUGE_MAX_HSTATE == 2.  I don't consider that to be expensive.
> 
> If you are concerned about the memory allocation of struct hugetlb_usage, 
> it could easily be embedded directly in struct mm_struct.

Yes I am concerned about that and
9 files changed, 112 insertions(+), 1 deletion(-)
for something that is even not clear to be really required. And I still
haven't heard any strong usecase to justify it.

Can we go with the single and much simpler cumulative number first and
only add the break down list if it is _really_ required? We can even
document that the future version of /proc/<pid>/status might add an
additional information to prepare all the parsers to be more careful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
