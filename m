Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8859F6B066F
	for <linux-mm@kvack.org>; Fri, 11 May 2018 11:45:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 39-v6so4758196qkx.0
        for <linux-mm@kvack.org>; Fri, 11 May 2018 08:45:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id a12-v6si1621139qkc.41.2018.05.11.08.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 May 2018 08:45:22 -0700 (PDT)
Date: Fri, 11 May 2018 10:45:19 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: mmotm 2018-05-10-16-34 uploaded (objtool)
Message-ID: <20180511154519.w6bbhptv67fvsgnr@treble>
References: <20180510233519.eYStA%akpm@linux-foundation.org>
 <aa27dcd5-8121-3da9-a6d8-2108a849986e@infradead.org>
 <20180511010122.xvkjqgx7yye77le3@treble>
 <b4c08470-b035-c735-9a1a-3dbf1f2804e2@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <b4c08470-b035-c735-9a1a-3dbf1f2804e2@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au, linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

On Thu, May 10, 2018 at 06:06:38PM -0700, Randy Dunlap wrote:
> >> Hi Josh, Peter:
> >>
> >> Is this something that you already have fixes for?
> >>
> >>
> >> on x86_64:
> >>
> >> drivers/video/fbdev/omap2/omapfb/dss/dispc.o: warning: objtool: dispc_runtime_suspend()+0xbb8: sibling call from callable instruction with modified stack frame
> >> drivers/video/fbdev/omap2/omapfb/dss/dispc.o: warning: objtool: dispc_runtime_resume()+0xcc5: sibling call from callable instruction with modified stack frame
> > 
> > I don't recall seeing that one.  Can you share the .config and/or .o
> > file?
> > 
> 
> Sure.  Both are attached.

Here's a fix (applies on top of the GCC 8 patches I posted this week):

diff --git a/tools/objtool/check.c b/tools/objtool/check.c
index 9bb04fddd3c8..a358489a1560 100644
--- a/tools/objtool/check.c
+++ b/tools/objtool/check.c
@@ -961,11 +961,15 @@ static struct rela *find_switch_table(struct objtool_file *file,
 		if (find_symbol_containing(file->rodata, text_rela->addend))
 			continue;
 
+		/* mov [rodata addr], %reg */
 		rodata_rela = find_rela_by_dest(file->rodata, text_rela->addend);
-		if (!rodata_rela)
-			continue;
+		if (rodata_rela)
+			return rodata_rela;
 
-		return rodata_rela;
+		/* mov [rodata_addr](%rip), %reg */
+		rodata_rela = find_rela_by_dest(file->rodata, text_rela->addend + 4);
+		if (rodata_rela)
+			return rodata_rela;
 	}
 
 	return NULL;
