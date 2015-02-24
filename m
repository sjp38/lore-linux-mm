Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 563476B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 19:20:08 -0500 (EST)
Received: by pablf10 with SMTP id lf10so31498998pab.6
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 16:20:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lw5si19060083pab.180.2015.02.23.16.20.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Feb 2015 16:20:07 -0800 (PST)
Date: Mon, 23 Feb 2015 16:20:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V5 0/4] Refactor do_wp_page, no functional change
Message-Id: <20150223162005.6eebce98b795699456464df4@linux-foundation.org>
In-Reply-To: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
References: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

On Sun, 22 Feb 2015 15:42:14 +0200 Shachar Raindel <raindel@mellanox.com> wrote:

> Currently do_wp_page contains 265 code lines. It also contains 9 goto
> statements, of which 5 are targeting labels which are not cleanup
> related. This makes the function extremely difficult to
> understand. The following patches are an attempt at breaking the
> function to its basic components, and making it easier to understand.
> 
> The patches are straight forward function extractions from
> do_wp_page. As we extract functions, we remove unneeded parameters and
> simplify the code as much as possible. However, the functionality is
> supposed to remain completely unchanged. The patches also attempt to
> document the functionality of each extracted function. In patch 2, we
> split the unlock logic to the contain logic relevant to specific needs
> of each use case, instead of having huge number of conditional
> decisions in a single unlock flow.

gcc-4.4.4:

   text    data     bss     dec     hex filename
  40898     186   13344   54428    d49c mm/memory.o-before
  41422     186   13456   55064    d718 mm/memory.o-after

gcc-4.8.2:

   text    data     bss     dec     hex filename
  35261   12118   13904   61283    ef63 mm/memory.o
  35646   12278   14032   61956    f204 mm/memory.o

The more recent compiler is more interesting but either way, that's a
somewhat disappointing increase in code size for refactoring of a
single function.

I had a brief poke around and couldn't find any obvious improvements
to make.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
