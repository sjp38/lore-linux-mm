Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0C2E46B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 02:38:18 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so35966843wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 23:38:17 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id hj19si8080442wib.3.2015.08.25.23.38.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 23:38:16 -0700 (PDT)
Received: by wicja10 with SMTP id ja10so34354311wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 23:38:15 -0700 (PDT)
Date: Wed, 26 Aug 2015 08:38:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Message-ID: <20150826063813.GA25196@dhcp22.suse.cz>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
 <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
 <20150821065321.GD23723@dhcp22.suse.cz>
 <20150821163033.GA4600@Sligo.logfs.org>
 <20150824085127.GB17078@dhcp22.suse.cz>
 <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1508251620570.10653@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: =?iso-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue 25-08-15 16:23:34, David Rientjes wrote:
> On Mon, 24 Aug 2015, Michal Hocko wrote:
> 
> > The current implementation makes me worry. Is the per hstate break down
> > really needed? The implementation would be much more easier without it.
> > 
> 
> Yes, it's needed.  It provides a complete picture of what statically 
> reserved hugepages are in use and we're not going to change the 
> implementation when it is needed to differentiate between variable hugetlb 
> page sizes that risk breaking existing userspace parsers.

I thought the purpose was to give the amount of hugetlb based
resident memory. At least this is what Jorn was asking for AFAIU.
/proc/<pid>/status should be as lightweight as possible. The current
implementation is quite heavy as already pointed out. So I am really
curious whether this is _really_ needed. I haven't heard about a real
usecase except for top displaying HRss which doesn't need the break
down values. You have brought that up already
http://marc.info/?l=linux-mm&m=143941143109335&w=2 and nobody actually
asked for it. "I do not mind having it" is not an argument for inclusion
especially when the implementation is more costly and touches hot paths.

> > If you have 99% of hugetlb pages then your load is rather specific and I
> > would argue that /proc/<pid>/smaps (after patch 1) is a much better way to
> > get what you want.
> 
> Some distributions change the permissions of smaps, as already stated, for 
> pretty clear security reasons since it can be used to defeat existing 
> protection.  There's no reason why hugetlb page usage should not be 
> exported in the same manner and location as memory usage.

/proc/<pid>/status provides only per-memory-type break down information
(locked, data, stack, etc...). Different hugetlb sizes are still a
hugetlb memory. So I am not sure I understand you argument here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
