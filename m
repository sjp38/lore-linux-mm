Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9896B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 06:40:01 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so4322147pdj.39
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 03:40:01 -0800 (PST)
Received: from psmtp.com ([74.125.245.177])
        by mx.google.com with SMTP id qu5si1400950pbc.180.2013.11.20.03.39.59
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 03:40:00 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Aliasing VIPT dcache / Page colouring
Date: Wed, 20 Nov 2013 11:39:54 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075156B6B@IN01WEMBXA.internal.synopsys.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hi Michal,

I read thru your fantastic work on Page coloring

http://d3s.mff.cuni.cz/publications/download/hocko-sipew10.pdf

and slightly different one at

http://citeseerx.ist.psu.edu/viewdoc/download?doi=3D10.1.1.65.2260&rep=3Dre=
p1&type=3Dpdf

I had a few questions on your paper/code, which you could hopefully answer.

To give you some background, I maintain the Linux port to ARC cores (from S=
ynopsys).  We have ARC700 core with VIPT, 4 way set associative, L1 dcache.=
 With a PAGE_SIZE of 8k, dcache >=3D 64k can potentially suffer from VIPT a=
liasing (we don't have specific hardware assist). Kernel runs in untranslat=
ed address space, hence uses paddr as handle for r/w to page, which can pot=
entially alias with a non congruent userspace mapping of page. Currently we=
 work around by doing the needed preventive flushes in update_mmu_cache( ) =
and other hooks intended for this purpose (although adding kmap_atomic base=
d mapping for @src in copy_user_highpage is still on my TODO list)

Regarding your paper/code I wanted to confirm my understanding that the sch=
eme itself can't be used in general for VIPT aliasing issue (ignoring the i=
ntrusiveness to core VM, Linus detesting it ...). It seems to be targeted a=
t large PIPT caches, primarily to help spread the cache access via coloring=
 / bin hopping etc. Plus it relies on user space defining the hints. The fi=
le backed page mapping doesn't take the color allocation path at all so I c=
an't see how it will work with VIPT at all. anon mappings cause pages alloc=
ation rightaway, breaking the lazy allocation paradigm.

Am I reading it correctly ?

TIA,
-Vineet

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
