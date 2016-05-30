Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C74F76B0260
	for <linux-mm@kvack.org>; Mon, 30 May 2016 05:15:08 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id j12so52431562lbo.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:08 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id 63si29681656wml.88.2016.05.30.02.15.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 02:15:07 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so20576774wmn.1
        for <linux-mm@kvack.org>; Mon, 30 May 2016 02:15:07 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/19] get rid of superfluous __GFP_REPEAT
Date: Mon, 30 May 2016 11:14:42 +0200
Message-Id: <1464599699-30131-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Chen Liqin <liqin.linux@gmail.com>, Chris Metcalf <cmetcalf@mellanox.com>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Heiko Carstens <heiko.carstens@de.ibm.com>, Helge Deller <deller@gmx.de>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jan Kara <jack@suse.cz>, John Crispin <blogic@openwrt.org>, Lennox Wu <lennox.wu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Fleming <matt@codeblueprint.co.uk>, Michal Hocko <mhocko@suse.com>, Rich Felker <dalias@libc.org>, Russell King <linux@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Thomas Gleixner <tglx@linutronix.de>, Vineet Gupta <vgupta@synopsys.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>

Hi,
this is the thrid version of the patchset previously sent [1]. I have
basically only rebased it on top of 4.7-rc1 tree and dropped "dm: get
rid of superfluous gfp flags" which went through dm tree. I am sending
it now because it is tree wide and chances for conflicts are reduced
considerably when we want to target rc2.  I plan to send the next step
and rename the flag and move to a better semantic later during this
release cycle so we will have a new semantic ready for 4.8 merge window
hopefully.

Motivation:
While working on something unrelated I've checked the current usage
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
semantic for it.

$ git grep __GFP_REPEAT origin/master | wc -l
111
$ git grep __GFP_REPEAT | wc -l
36

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

[1] http://lkml.kernel.org/r/1461849846-27209-1-git-send-email-mhocko@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
