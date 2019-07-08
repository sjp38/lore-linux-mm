Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F632C606C2
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1924F2173E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ff+jbNUQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1924F2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99E748E001D; Mon,  8 Jul 2019 11:31:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94EED8E001C; Mon,  8 Jul 2019 11:31:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8165A8E001D; Mon,  8 Jul 2019 11:31:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D38F8E001C
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 11:31:16 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id i12so14044336qtq.4
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 08:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Y2ttJ+jo2vlTHZtmeKQk/YmO15ANmcNzgtC/1x2Dm4I=;
        b=esyhIoK5CotjcXkqTOL+di6dipqzDX08lljOFKkn043m3NXx10NS7hDWecfiTy2PpP
         Gt/yfYmwjHKTU50nsF0gUp+WdzveJhUJ9GH0RBSJeb3DFXe/GFJFt9vnWOylpnjaEaMt
         kU8JcIM6AmVh6yHfRDjxHllS32NQ3VV3yzmTMcq3/gEQgzfKPb+yj5Igwrh94NmyqAAF
         BNuYM4pchrKikNiXE4+R9QKNV+v1csXavRacsXPviY3bH73MMsPfsn2T9dP0bUPWP5gV
         yn6zoLFA5OPgLn+Dle60HuOz4X52AL0iYBDYtKMAB1xB7E6peuIzcW+GV4aEhHYzKeqv
         nJXw==
X-Gm-Message-State: APjAAAVT/8RstS3gRLJ/E1SVNbW74xi7IX0f8v9kGYyf87lo7agF+SfP
	352XUA0jAU/CGw8OEqyQSXKGV0Aj0k+njIU5RAMuW2peqaThiQJemU1HlfqepcpazV95uCjTx0b
	TBHGjEJA6xa2jX/LBAiOfJntxK4Vu4ZaMUixQ87iCA2FgIaUSs02OgII4HaIjxp5B1w==
X-Received: by 2002:a05:620a:10bc:: with SMTP id h28mr14769209qkk.289.1562599876025;
        Mon, 08 Jul 2019 08:31:16 -0700 (PDT)
X-Received: by 2002:a05:620a:10bc:: with SMTP id h28mr14769135qkk.289.1562599875109;
        Mon, 08 Jul 2019 08:31:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562599875; cv=none;
        d=google.com; s=arc-20160816;
        b=e/tG8vaUxqzXMcItqGato0Dc3pDrqz+H+WKCxk59sgHhR0Sd6Tc4ymDdCeOxZTH9rD
         VC+wplsK+DCBrIa0AFDmckAwCgmYuws1O7CIi5w5+fcF01/6AoDhyAUY/Vgnah87Mr0B
         EtDTZjdCYYgIZF0NHJ7GIvaaWtkNXBefuZ8geq7JlB7+dbLt6+19JWacSfeg09FqiNP2
         VN/xTTEpNI0aYRrRuwy3SokdoRNHOdb7KGuC97HoRXOeT4TVW6qLQm41ug+h7V6BaafK
         I0XLkGM3yWHR6/dx/kc5w0MmB2rnaAqAWWzw6eOq9OwIhFSXMAXHjl3ISy/ZlHphQgfF
         EUGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Y2ttJ+jo2vlTHZtmeKQk/YmO15ANmcNzgtC/1x2Dm4I=;
        b=q36wLxj2W3mfewfpnRKb0kWqeT16EVseJZArLmkTdeXcIh5NoF4boef8aDHtRl57nC
         MUY8QnwxC1bGRuUeWXolLKgRaSMOvLmABHwewltcZ7zCDiOueGWF2ffa6bvj/ShcoL1l
         cBMn3saTSDTZ8umJZpV0xOR65aocsrhofQxC5O/ViQ5axJDoL3oRvEHg6+tAN82FLFLe
         gxAs6xKOls0ZtAPd3xZzM3+Yz9gW8KcCuw18CEmhG6RVq1ehw6cGGUGasNigN2ebvYk5
         hsVs0P2ldF2gKG6UR+xvTCf3LTOP5+Dlq3V1AsXLpT9/WwNCX9wiR0i4gz+ozxt/VB3p
         n+bg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ff+jbNUQ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor1130403qvj.46.2019.07.08.08.31.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 08:31:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ff+jbNUQ;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Y2ttJ+jo2vlTHZtmeKQk/YmO15ANmcNzgtC/1x2Dm4I=;
        b=ff+jbNUQ8pXpBPpDqrkwHxFvInTeLQtC5bW4PZL5Sfg7KO4IEXTdWDV+by/ZoiUQb+
         iz7XsilIgVsFQgAQUpttHczs+eaD2e3BnHeNF2dtfD9choaJC69k3gfNxfq8+OKBySLE
         nGZ+Djzt0Lne8gcJI3a9NFAYDwkg+N3XyQlxpqcdTBkHFDXk9h7mmE9KTfo9f/RpELcp
         qp003TiwEI5ZI9tvSp5yyYdam/PAiVTUrd1ASa7W1EjF+WwF0qjSrKCbDX3yk1+UdQZ9
         UZO2j6dkzK0swSMG8rhCtc0vKU+CzvodTyuHTzqvAhzSWGmOhmWS3YKKhfaUePyJ3Le2
         sqkw==
X-Google-Smtp-Source: APXvYqyFp1GCF2q5+jGJlUX6leNmtG4hZ95iO5bi2rXlGWEbJsn7wmvrrnYkzLWpeUyTODO8ICNuGA==
X-Received: by 2002:a0c:e703:: with SMTP id d3mr14867023qvn.194.1562599874723;
        Mon, 08 Jul 2019 08:31:14 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id 47sm10275217qtw.90.2019.07.08.08.31.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 08:31:14 -0700 (PDT)
Message-ID: <1562599872.8510.3.camel@lca.pw>
Subject: Re: [linux-next:master 12285/12641]
 include/linux/kasan-checks.h:25:20: error: inlining failed in call to
 always_inline 'kasan_check_read': function attribute mismatch
From: Qian Cai <cai@lca.pw>
To: kbuild test robot <lkp@intel.com>, Marco Elver <elver@google.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux
	Memory Management List
	 <linux-mm@kvack.org>
Date: Mon, 08 Jul 2019 11:31:12 -0400
In-Reply-To: <201907052106.cFRkjebu%lkp@intel.com>
References: <201907052106.cFRkjebu%lkp@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Confirmed that reverting the series fixed the compilation error on x86.

254fb04d207a Revert "mm/kasan: introduce __kasan_check_{read,write}"
ea13ff3c419e Revert "mm/kasan: change kasan_check_{read,write} to return
boolean"
f985089f2720 Revert "mm/kasan: include types.h for "bool""
189d618780b9 Revert "lib/test_kasan: Add test for double-kzfree detection"
9ff8c87f0bc1 Revert "mm/slab: refactor common ksize KASAN logic into
slab_common.c"
f70e2a0186e8 Revert "mm/kasan: add object validation in ksize()"
d9cc021b1ab1 Revert "mm-kasan-add-object-validation-in-ksize-v4"

In file included from ./include/linux/compiler.h:257,
                 from ./arch/x86/include/asm/current.h:5,
                 from ./include/linux/sched.h:12,
                 from ./include/linux/ratelimit.h:6,
                 from fs/dcache.c:18:
./include/linux/compiler.h: In function ‘read_word_at_a_time’:
./include/linux/kasan-checks.h:31:20: error: inlining failed in call to
always_inline ‘kasan_check_read’: function attribute mismatch
 static inline bool kasan_check_read(const volatile void *p, unsigned int size)
                    ^~~~~~~~~~~~~~~~
In file included from ./arch/x86/include/asm/current.h:5,
                 from ./include/linux/sched.h:12,
                 from ./include/linux/ratelimit.h:6,
                 from fs/dcache.c:18:
./include/linux/compiler.h:280:2: note: called from here
  kasan_check_read(addr, 1);
  ^~~~~~~~~~~~~~~~~~~~~~~~~
make[1]: *** [scripts/Makefile.build:279: fs/dcache.o] Error 1

On Fri, 2019-07-05 at 21:51 +0800, kbuild test robot wrote:
> tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-ne
> xt.git master
> head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
> commit: 452b72b9f28f8bdf0e030c827f2b366d4661fd50 [12285/12641] mm/kasan:
> introduce __kasan_check_{read,write}
> config: x86_64-randconfig-s1-07051907 (attached as .config)
> compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
> reproduce:
>         git checkout 452b72b9f28f8bdf0e030c827f2b366d4661fd50
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    Cyclomatic Complexity 6 fs/dcache.c:d_same_name
>    Cyclomatic Complexity 1 fs/dcache.c:__d_rehash
>    Cyclomatic Complexity 1 fs/dcache.c:d_rehash
>    Cyclomatic Complexity 4 fs/dcache.c:start_dir_add
>    Cyclomatic Complexity 1 fs/dcache.c:end_dir_add
>    Cyclomatic Complexity 12 fs/dcache.c:__d_add
>    Cyclomatic Complexity 9 fs/dcache.c:__d_find_alias
>    Cyclomatic Complexity 3 fs/dcache.c:d_find_alias
>    Cyclomatic Complexity 14 fs/dcache.c:d_exact_alias
>    Cyclomatic Complexity 10 fs/dcache.c:d_genocide_kill
>    Cyclomatic Complexity 4 fs/dcache.c:dcache_init_early
>    Cyclomatic Complexity 4 fs/dcache.c:dcache_init
>    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry
>    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry_unused
>    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry_negative
>    Cyclomatic Complexity 3 fs/dcache.c:___d_drop
>    Cyclomatic Complexity 3 fs/dcache.c:__d_drop
>    Cyclomatic Complexity 1 fs/dcache.c:d_drop
>    Cyclomatic Complexity 6 fs/dcache.c:__lock_parent
>    Cyclomatic Complexity 21 fs/dcache.c:shrink_lock_dentry
>    Cyclomatic Complexity 3 fs/dcache.c:d_shrink_del
>    Cyclomatic Complexity 5 fs/dcache.c:path_check_mount
>    Cyclomatic Complexity 3 fs/dcache.c:d_shrink_add
>    Cyclomatic Complexity 29 fs/dcache.c:d_set_d_op
>    Cyclomatic Complexity 19 fs/dcache.c:d_flags_for_inode
>    Cyclomatic Complexity 6 fs/dcache.c:__d_instantiate
>    Cyclomatic Complexity 3 fs/dcache.c:take_dentry_name_snapshot
>    Cyclomatic Complexity 8 fs/dcache.c:swap_names
>    Cyclomatic Complexity 5 fs/dcache.c:release_dentry_name_snapshot
>    Cyclomatic Complexity 8 fs/dcache.c:copy_name
>    Cyclomatic Complexity 7 fs/dcache.c:d_lru_add
>    Cyclomatic Complexity 7 fs/dcache.c:d_lru_del
>    Cyclomatic Complexity 16 fs/dcache.c:select_collect
>    Cyclomatic Complexity 12 fs/dcache.c:dentry_unlink_inode
>    Cyclomatic Complexity 1 fs/dcache.c:__d_free_external
>    Cyclomatic Complexity 1 fs/dcache.c:__d_free
>    Cyclomatic Complexity 10 fs/dcache.c:dentry_free
>    Cyclomatic Complexity 32 fs/dcache.c:__dentry_kill
>    Cyclomatic Complexity 28 fs/dcache.c:dentry_kill
>    Cyclomatic Complexity 6 fs/dcache.c:dput
>    Cyclomatic Complexity 12 fs/dcache.c:d_prune_aliases
>    Cyclomatic Complexity 15 fs/dcache.c:shrink_dentry_list
>    Cyclomatic Complexity 2 fs/dcache.c:shrink_dcache_sb
>    Cyclomatic Complexity 8 fs/dcache.c:dget_parent
>    Cyclomatic Complexity 5 fs/dcache.c:d_lru_isolate
>    Cyclomatic Complexity 5 fs/dcache.c:d_lru_shrink_move
>    Cyclomatic Complexity 9 fs/dcache.c:dentry_lru_isolate
>    Cyclomatic Complexity 3 fs/dcache.c:dentry_lru_isolate_shrink
>    Cyclomatic Complexity 26 fs/dcache.c:d_walk
>    Cyclomatic Complexity 1 fs/dcache.c:path_has_submounts
>    Cyclomatic Complexity 6 fs/dcache.c:shrink_dcache_parent
>    Cyclomatic Complexity 1 fs/dcache.c:do_one_tree
>    Cyclomatic Complexity 12 fs/dcache.c:d_invalidate
>    Cyclomatic Complexity 1 fs/dcache.c:d_genocide
>    Cyclomatic Complexity 14 fs/dcache.c:umount_check
>    Cyclomatic Complexity 5 fs/dcache.c:d_instantiate
>    Cyclomatic Complexity 10 fs/dcache.c:__d_instantiate_anon
>    Cyclomatic Complexity 1 fs/dcache.c:d_instantiate_anon
>    Cyclomatic Complexity 4 fs/dcache.c:d_add
>    Cyclomatic Complexity 5 fs/dcache.c:d_instantiate_new
>    Cyclomatic Complexity 4 fs/dcache.c:d_delete
>    Cyclomatic Complexity 6 fs/dcache.c:d_wait_lookup
>    Cyclomatic Complexity 1 fs/dcache.c:__d_lookup_done
>    Cyclomatic Complexity 6 fs/dcache.c:d_tmpfile
>    Cyclomatic Complexity 4 fs/dcache.c:set_dhash_entries
>    Cyclomatic Complexity 2 fs/dcache.c:vfs_caches_init_early
>    Cyclomatic Complexity 1 fs/dcache.c:vfs_caches_init
>    Cyclomatic Complexity 1 fs/dcache.c:proc_nr_dentry
>    Cyclomatic Complexity 1 fs/dcache.c:prune_dcache_sb
>    Cyclomatic Complexity 8 fs/dcache.c:d_set_mounted
>    Cyclomatic Complexity 4 fs/dcache.c:shrink_dcache_for_umount
>    Cyclomatic Complexity 25 fs/dcache.c:__d_alloc
>    Cyclomatic Complexity 4 fs/dcache.c:d_alloc
>    Cyclomatic Complexity 1 fs/dcache.c:d_alloc_name
>    Cyclomatic Complexity 1 fs/dcache.c:d_alloc_anon
>    Cyclomatic Complexity 7 fs/dcache.c:d_make_root
>    Cyclomatic Complexity 12 fs/dcache.c:__d_obtain_alias
>    Cyclomatic Complexity 1 fs/dcache.c:d_obtain_alias
>    Cyclomatic Complexity 1 fs/dcache.c:d_obtain_root
>    Cyclomatic Complexity 4 fs/dcache.c:d_alloc_cursor
>    Cyclomatic Complexity 3 fs/dcache.c:d_alloc_pseudo
>    Cyclomatic Complexity 22 fs/dcache.c:__d_lookup_rcu
>    Cyclomatic Complexity 35 fs/dcache.c:d_alloc_parallel
>    Cyclomatic Complexity 13 fs/dcache.c:__d_lookup
>    Cyclomatic Complexity 5 fs/dcache.c:d_lookup
>    Cyclomatic Complexity 6 fs/dcache.c:d_hash_and_lookup
>    Cyclomatic Complexity 5 fs/dcache.c:d_ancestor
>    Cyclomatic Complexity 42 fs/dcache.c:__d_move
>    Cyclomatic Complexity 1 fs/dcache.c:d_move
>    Cyclomatic Complexity 9 fs/dcache.c:d_exchange
>    Cyclomatic Complexity 14 fs/dcache.c:__d_unalias
>    Cyclomatic Complexity 22 fs/dcache.c:d_splice_alias
>    Cyclomatic Complexity 15 fs/dcache.c:d_add_ci
>    Cyclomatic Complexity 7 fs/dcache.c:is_subdir
>    In file included from include/linux/compiler.h:252:0,
>                     from arch/x86/include/asm/current.h:5,
>                     from include/linux/sched.h:12,
>                     from include/linux/ratelimit.h:6,
>                     from fs/dcache.c:18:
>    include/linux/compiler.h: In function 'read_word_at_a_time':
> > > include/linux/kasan-checks.h:25:20: error: inlining failed in call to
> > > always_inline 'kasan_check_read': function attribute mismatch
> 
>     static inline void kasan_check_read(const volatile void *p, unsigned int
> size)
>                        ^~~~~~~~~~~~~~~~
>    In file included from arch/x86/include/asm/current.h:5:0,
>                     from include/linux/sched.h:12,
>                     from include/linux/ratelimit.h:6,
>                     from fs/dcache.c:18:
>    include/linux/compiler.h:275:2: note: called from here
>      kasan_check_read(addr, 1);
>      ^~~~~~~~~~~~~~~~~~~~~~~~~
> --
>    Cyclomatic Complexity 1 include/linux/kasan-checks.h:kasan_check_read
>    Cyclomatic Complexity 1 include/linux/compiler.h:read_word_at_a_time
>    Cyclomatic Complexity 4 include/linux/ctype.h:__tolower
>    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> time.h:count_masked_bytes
>    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-time.h:has_zero
>    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> time.h:prep_zero_mask
>    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> time.h:create_zero_mask
>    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-time.h:find_zero
>    Cyclomatic Complexity 2 lib/string.c:strcasecmp
>    Cyclomatic Complexity 2 lib/string.c:strcpy
>    Cyclomatic Complexity 4 lib/string.c:strncpy
>    Cyclomatic Complexity 3 lib/string.c:strcat
>    Cyclomatic Complexity 3 lib/string.c:strchrnul
>    Cyclomatic Complexity 2 lib/string.c:skip_spaces
>    Cyclomatic Complexity 2 lib/string.c:strlen
>    Cyclomatic Complexity 3 lib/string.c:strnlen
>    Cyclomatic Complexity 4 lib/string.c:memcmp
>    Cyclomatic Complexity 1 lib/string.c:bcmp
>    Cyclomatic Complexity 4 lib/string.c:memchr
>    Cyclomatic Complexity 14 lib/string.c:strncasecmp
>    Cyclomatic Complexity 20 lib/string.c:strscpy
>    Cyclomatic Complexity 8 lib/string.c:strncat
>    Cyclomatic Complexity 8 lib/string.c:strcmp
>    Cyclomatic Complexity 9 lib/string.c:strncmp
>    Cyclomatic Complexity 5 lib/string.c:strchr
>    Cyclomatic Complexity 5 lib/string.c:strrchr
>    Cyclomatic Complexity 6 lib/string.c:strnchr
>    Cyclomatic Complexity 6 lib/string.c:strim
>    Cyclomatic Complexity 9 lib/string.c:strspn
>    Cyclomatic Complexity 6 lib/string.c:strcspn
>    Cyclomatic Complexity 6 lib/string.c:strpbrk
>    Cyclomatic Complexity 7 lib/string.c:strsep
>    Cyclomatic Complexity 28 lib/string.c:sysfs_streq
>    Cyclomatic Complexity 8 lib/string.c:match_string
>    Cyclomatic Complexity 7 lib/string.c:__sysfs_match_string
>    Cyclomatic Complexity 5 lib/string.c:memscan
>    Cyclomatic Complexity 8 lib/string.c:strstr
>    Cyclomatic Complexity 8 lib/string.c:strnstr
>    Cyclomatic Complexity 5 lib/string.c:check_bytes8
>    Cyclomatic Complexity 14 lib/string.c:memchr_inv
>    Cyclomatic Complexity 5 lib/string.c:strreplace
>    Cyclomatic Complexity 5 lib/string.c:strlcpy
>    Cyclomatic Complexity 9 lib/string.c:strscpy_pad
>    Cyclomatic Complexity 1 lib/string.c:memzero_explicit
>    Cyclomatic Complexity 5 lib/string.c:strlcat
>    Cyclomatic Complexity 0 lib/string.c:fortify_panic
>    In file included from include/linux/compiler.h:252:0,
>                     from include/linux/string.h:6,
>                     from lib/string.c:24:
>    include/linux/compiler.h: In function 'read_word_at_a_time':
> > > include/linux/kasan-checks.h:25:20: error: inlining failed in call to
> > > always_inline 'kasan_check_read': function attribute mismatch
> 
>     static inline void kasan_check_read(const volatile void *p, unsigned int
> size)
>                        ^~~~~~~~~~~~~~~~
>    In file included from include/linux/string.h:6:0,
>                     from lib/string.c:24:
>    include/linux/compiler.h:275:2: note: called from here
>      kasan_check_read(addr, 1);
>      ^~~~~~~~~~~~~~~~~~~~~~~~~
> 
> vim +/kasan_check_read +25 include/linux/kasan-checks.h
> 
>     19	
>     20	/*
>     21	 * kasan_check_*: Only available when the particular compilation
> unit has KASAN
>     22	 * instrumentation enabled. May be used in header files.
>     23	 */
>     24	#ifdef __SANITIZE_ADDRESS__
>   > 25	static inline void kasan_check_read(const volatile void *p,
> unsigned int size)
>     26	{
>     27		__kasan_check_read(p, size);
>     28	}
>     29	static inline void kasan_check_write(const volatile void *p,
> unsigned int size)
>     30	{
>     31		__kasan_check_read(p, size);
>     32	}
>     33	#else
>     34	static inline void kasan_check_read(const volatile void *p,
> unsigned int size)
>     35	{ }
>     36	static inline void kasan_check_write(const volatile void *p,
> unsigned int size)
>     37	{ }
>     38	#endif
>     39	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

