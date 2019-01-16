Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E8F858E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:43:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t7so2143816edr.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:43:00 -0800 (PST)
Received: from outbound-smtp25.blacknight.com (outbound-smtp25.blacknight.com. [81.17.249.193])
        by mx.google.com with ESMTPS id d8-v6si5481229ejp.161.2019.01.16.01.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 01:42:59 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp25.blacknight.com (Postfix) with ESMTPS id DDF2AB88B1
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:42:58 +0000 (GMT)
Date: Wed, 16 Jan 2019 09:42:57 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/25] mm, compaction: Skip pageblocks with reserved pages
Message-ID: <20190116094257.GB27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-7-mgorman@techsingularity.net>
 <657ee6fc-48df-59ab-70b7-6066513e3b22@suse.cz>
 <20190115125045.GA27437@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190115125045.GA27437@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Tue, Jan 15, 2019 at 12:50:45PM +0000, Mel Gorman wrote:
> > AFAICS memory allocator is not the only user of PageReserved. There
> > seems to be some drivers as well, notably the DRM subsystem via
> > drm_pci_alloc(). There's an effort to clean those up [1] but until then,
> > there might be some false positives here.
> > 
> > [1] https://marc.info/?l=linux-mm&m=154747078617898&w=2
> > 
> 
> Hmm, I'm tempted to leave this anyway. The reservations for PCI space are
> likely to be persistent and I also do not expect them to grow much. While
> I consider it to be partially abuse to use PageReserved like this, it
> should get cleaned up slowly over time. If this turns out to be wrong,
> I'll attempt to fix the responsible driver that is scattering
> PageReserved around the place and at worst, revert this if it turns out
> to be a major problem in practice. Any objections?
> 

I decided to drop this anyway as the series does not hinge on it, it's a
relatively minor improvement overall and I don't want to halt the entire
series over it. The maintain that the system would recover even if the
driver released the pages as the check would eventually fail and then be
cleared after a reset. The only downside from the patch that I can see
really is that it's a small maintenance overhead due to an apparent
duplicated check. The CPU overhead of compaction will be slightly higher
due to the revert but there are other options on the horizon that would
bring down that overhead again.

-- 
Mel Gorman
SUSE Labs
