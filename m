Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 025A66B0005
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 07:08:22 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id u206so99240606wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:21 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id w2si17798027wma.29.2016.04.11.04.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 04:08:20 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id a140so20426905wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:08:20 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/19] get rid of superfluous __GFP_REPORT
Date: Mon, 11 Apr 2016 13:07:53 +0200
Message-Id: <1460372892-8157-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.linux@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Helge Deller <deller@gmx.de>, Herbert Xu <herbert@gondor.apana.org.au>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, John Crispin <blogic@openwrt.org>, Lennox Wu <lennox.wu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Matt Fleming <matt@codeblueprint.co.uk>, Michal Hocko <mhocko@suse.com>, Mikulas Patocka <mpatocka@redhat.com>, Rich Felker <dalias@libc.org>, Russell King <linux@arm.linux.org.uk>, Shaohua Li <shli@kernel.org>, Theodore Ts'o <tytso@mit.edu>, Thomas Gleixner <tglx@linutronix.de>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>

Hi,
this is the second version of the patchset previously sent [1]

while working on something unrelated I've checked the current usage
of __GFP_REPEAT in the tree. It seems that a majority of the usage is
and always has been bogus because __GFP_REPEAT has always been about
costly high order allocations while we are using it for order-0 or very
small orders very often. It seems that a big pile of them is just a
copy&paste when a code has been adopted from one arch to another.

I think it makes some sense to get rid of them because they are just
making the semantic more unclear. Please note that GFP_REPEAT is
documented as
 * __GFP_REPEAT: Try hard to allocate the memory, but the allocation attempt
 *   _might_ fail.  This depends upon the particular VM implementation.
while !costly requests have basically nofail semantic. So one could
reasonably expect that order-0 request with __GFP_REPEAT will not loop
for ever. This is not implemented right now though.

I would like to move on with __GFP_REPEAT and define a better
semantic for it. One thought was to rename it to __GFP_BEST_EFFORT
which would behave consistently for all orders and guarantee that the
allocation would try as long as it seem feasible or fail eventually.
!costly request would then finally get a request context which neiter
fails too early (GFP_NORETRY) nor endlessly loops in the allocator for
ever (default behavior). Costly high order requests would keep the
current semantic.

$ git grep __GFP_REPEAT next/master | wc -l
111
$ git grep __GFP_REPEAT | wc -l
35

So we are down to the third after this patch series. The remaining places
really seem to be relying on __GFP_REPEAT due to large allocation requests.
This still needs some double checking which I will do later after all the
simple ones are sorted out.

I am touching a lot of arch specific code here and I hope I got it right
but as a matter of fact I even didn't compile test for some archs as I
do not have cross compiler for them. Patches should be quite trivial to
review for stupid compile mistakes though. The tricky parts are usually
hidden by macro definitions and thats where I would appreciate help from
arch maintainers.

I am also interested whether this makes sense in general.

[1] http://lkml.kernel.org/r/1446740160-29094-1-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
