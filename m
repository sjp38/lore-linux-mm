Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1E2BC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 472C921479
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 17:11:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fKlNUbEh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 472C921479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBEC28E0002; Mon,  8 Jul 2019 13:11:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D70758E0027; Mon,  8 Jul 2019 13:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C38338E0028; Mon,  8 Jul 2019 13:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A10B8E0027
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 13:11:46 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id i16so6397715oie.1
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 10:11:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=jCMU2NGOxNxWZw5bczjrbWm+HWw+bajBnewnzaxx8hY=;
        b=ILU0yA5v2dlmnTVEItIXNp7Zx7O+Tb51zh3KkDRxYxT6udR+RkFslGcVZ4x88eA/7F
         HkDZeYDWC9UrIcFTU9kwDl7dRJ5uQ9LJ7+yvlpbDqKlNe+s4583lf9+4hvSviYPvDDJR
         9w6Fdh6XX/ouSTdEkRKpVUVi1RIbl8gBWwl9oJOLZfQzXKh/TOQaqq9jTttdW8TcBD1s
         JoUyyIe/0JGQFWVEdfLP3iHjlNMIX2TB7cgsGmWvdwMFPx8U5kawj6qAn4seKcjxgek8
         1G+DhaWXa8doZ/T5CS4m76N9LtoY0xKeaOB9NQ+ojTNFs6/by9bceLAH+M8+7Bmqa8RS
         NMPg==
X-Gm-Message-State: APjAAAXQh7Kc0k7wN+k1GRiH1AM4cD646Q+JyTTIcTGJfU7WH0OxjmBk
	R7ojGvDs5iwKRAKGiP6FoJELZVlgTFrUFWzQ76cXF6rSIi5jCF2w7Dg9dLzdfG4HyP5/Rihplqw
	iW128uCIFbV9e2kv75Lmi8Be17xaSurTzl07Ev3XFuzjw8+6DBdcb6x/5L51yWTIAzA==
X-Received: by 2002:aca:4a8f:: with SMTP id x137mr9808577oia.67.1562605906211;
        Mon, 08 Jul 2019 10:11:46 -0700 (PDT)
X-Received: by 2002:aca:4a8f:: with SMTP id x137mr9808525oia.67.1562605905145;
        Mon, 08 Jul 2019 10:11:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562605905; cv=none;
        d=google.com; s=arc-20160816;
        b=MvqM8EqmFHIBIRKmS2jn5yMCiTvgJXexIn/wq4ZlaMkjZOspLYhmXevOhS0xF3NcL4
         ZWxb+Z59BaU1Ymh7RZCIzd+RJMKdfvatcWiDPaS6sFMnwB7wfNISMa25BJJnTcuuCnT0
         y7EtiQvzzHOmDrnY3kg4Rh1lYyxYqeEs/nn9Rk/C+q3mFQjTBrQXJmkawK+nr2WOaEyk
         aY5NW8w9+rVOsV5avXtCoN/QK1BsRsUY1epPNI1ei/KSqr/uK47Bg3pY2yqml1lBLasq
         aZCEBD0woC7fHlfAmLpcyyWY/eKHVe2B9irTbmOiN+wmizNMYE3QPQatnMa0zMCUfmZP
         ahxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=jCMU2NGOxNxWZw5bczjrbWm+HWw+bajBnewnzaxx8hY=;
        b=IVzRopiMg6Z/LYRybwOLTqrDXyfuEOOjA5K5uUtQaniJl68XHtSKkyEkiKzJzeih1N
         y/YmgXhIHdYC/M59BYtBzByTy4LFwHxIjOsP/gsnT3ad178ItFW0f9db7FK/Vfh5NOyh
         UPLqdePF4FwRieyKyKZgb0nfCe//bvt/rURV4ixPg1+d9oTy0ymQb2ckTn5paU+7Om08
         /tZlqSrp0m4MZ3nlwBDdf/O26uOMvhuztU7gqIjQIrJAyUoJO2jnEWJQNka1zBCcy+86
         50N2btdMw4QtGgjzXGYmyynmnReY7iJJ2sd33Puy6/U7/HIeI0un7kHHBzvNPn5wt7V7
         m5CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fKlNUbEh;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c17sor8649988otk.82.2019.07.08.10.11.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 10:11:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fKlNUbEh;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=jCMU2NGOxNxWZw5bczjrbWm+HWw+bajBnewnzaxx8hY=;
        b=fKlNUbEhn4cCVX7OR9iBB06vEiRKaAHq+tqI1ctP8dCevtBi2CsmziNLh4UIGq0wVb
         etKIM/i64csObM1ae12BwjVOJhcpWsCX20t10tjG09wskZZdG9Wi8FdzrItnEfHbX/DL
         wej/KOraJKIAmncVD+LEdUJ7TO+elRzsLvA4Q38/AoKGAMi0F8kfLcQM09EZFIOorezp
         +NRivKoQ/Bereg0Dn63Ci+DFB/O1U8rzALJbmdbCfE5sK39lPdkrHj+ksqagaNROtyj/
         KjjGyb4UneWIIr+Ajtb7jhpv79CQuVCWiq2k1mPxYEMqvEm8PEC65jPCaeAFkFmqRMFA
         76nQ==
X-Google-Smtp-Source: APXvYqxCwDn3CrckGfGEk7BLBYRxiOAcTQcWFhtI3G+zsNAa60qG/UpfrcJ3ud2FhDgMNAN2qhCCKRxmUEEA4v7FN+U=
X-Received: by 2002:a9d:57c6:: with SMTP id q6mr15102991oti.17.1562605904489;
 Mon, 08 Jul 2019 10:11:44 -0700 (PDT)
MIME-Version: 1.0
References: <201907052106.cFRkjebu%lkp@intel.com> <1562599872.8510.3.camel@lca.pw>
In-Reply-To: <1562599872.8510.3.camel@lca.pw>
From: Marco Elver <elver@google.com>
Date: Mon, 8 Jul 2019 19:11:33 +0200
Message-ID: <CANpmjNPp0dx78rhF3om-Ua8bq1Rd-3NP=iDnU6ZNd+Zp6-B0JA@mail.gmail.com>
Subject: Re: [linux-next:master 12285/12641] include/linux/kasan-checks.h:25:20:
 error: inlining failed in call to always_inline 'kasan_check_read': function
 attribute mismatch
To: Qian Cai <cai@lca.pw>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jul 2019 at 17:31, Qian Cai <cai@lca.pw> wrote:
>
> Confirmed that reverting the series fixed the compilation error on x86.

Thanks!  I've just sent v5 which addresses the issue:
http://lkml.kernel.org/r/20190708170706.174189-1-elver@google.com

> 254fb04d207a Revert "mm/kasan: introduce __kasan_check_{read,write}"
> ea13ff3c419e Revert "mm/kasan: change kasan_check_{read,write} to return
> boolean"
> f985089f2720 Revert "mm/kasan: include types.h for "bool""
> 189d618780b9 Revert "lib/test_kasan: Add test for double-kzfree detection=
"
> 9ff8c87f0bc1 Revert "mm/slab: refactor common ksize KASAN logic into
> slab_common.c"
> f70e2a0186e8 Revert "mm/kasan: add object validation in ksize()"
> d9cc021b1ab1 Revert "mm-kasan-add-object-validation-in-ksize-v4"
>
> In file included from ./include/linux/compiler.h:257,
>                  from ./arch/x86/include/asm/current.h:5,
>                  from ./include/linux/sched.h:12,
>                  from ./include/linux/ratelimit.h:6,
>                  from fs/dcache.c:18:
> ./include/linux/compiler.h: In function =E2=80=98read_word_at_a_time=E2=
=80=99:
> ./include/linux/kasan-checks.h:31:20: error: inlining failed in call to
> always_inline =E2=80=98kasan_check_read=E2=80=99: function attribute mism=
atch
>  static inline bool kasan_check_read(const volatile void *p, unsigned int=
 size)
>                     ^~~~~~~~~~~~~~~~
> In file included from ./arch/x86/include/asm/current.h:5,
>                  from ./include/linux/sched.h:12,
>                  from ./include/linux/ratelimit.h:6,
>                  from fs/dcache.c:18:
> ./include/linux/compiler.h:280:2: note: called from here
>   kasan_check_read(addr, 1);
>   ^~~~~~~~~~~~~~~~~~~~~~~~~
> make[1]: *** [scripts/Makefile.build:279: fs/dcache.o] Error 1
>
> On Fri, 2019-07-05 at 21:51 +0800, kbuild test robot wrote:
> > tree:   https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/l=
inux-ne
> > xt.git master
> > head:   22c45ec32b4a9fa8c48ef4f5bf9b189b307aae12
> > commit: 452b72b9f28f8bdf0e030c827f2b366d4661fd50 [12285/12641] mm/kasan=
:
> > introduce __kasan_check_{read,write}
> > config: x86_64-randconfig-s1-07051907 (attached as .config)
> > compiler: gcc-7 (Debian 7.4.0-9) 7.4.0
> > reproduce:
> >         git checkout 452b72b9f28f8bdf0e030c827f2b366d4661fd50
> >         # save the attached .config to linux build tree
> >         make ARCH=3Dx86_64
> >
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> >
> > All errors (new ones prefixed by >>):
> >
> >    Cyclomatic Complexity 6 fs/dcache.c:d_same_name
> >    Cyclomatic Complexity 1 fs/dcache.c:__d_rehash
> >    Cyclomatic Complexity 1 fs/dcache.c:d_rehash
> >    Cyclomatic Complexity 4 fs/dcache.c:start_dir_add
> >    Cyclomatic Complexity 1 fs/dcache.c:end_dir_add
> >    Cyclomatic Complexity 12 fs/dcache.c:__d_add
> >    Cyclomatic Complexity 9 fs/dcache.c:__d_find_alias
> >    Cyclomatic Complexity 3 fs/dcache.c:d_find_alias
> >    Cyclomatic Complexity 14 fs/dcache.c:d_exact_alias
> >    Cyclomatic Complexity 10 fs/dcache.c:d_genocide_kill
> >    Cyclomatic Complexity 4 fs/dcache.c:dcache_init_early
> >    Cyclomatic Complexity 4 fs/dcache.c:dcache_init
> >    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry
> >    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry_unused
> >    Cyclomatic Complexity 2 fs/dcache.c:get_nr_dentry_negative
> >    Cyclomatic Complexity 3 fs/dcache.c:___d_drop
> >    Cyclomatic Complexity 3 fs/dcache.c:__d_drop
> >    Cyclomatic Complexity 1 fs/dcache.c:d_drop
> >    Cyclomatic Complexity 6 fs/dcache.c:__lock_parent
> >    Cyclomatic Complexity 21 fs/dcache.c:shrink_lock_dentry
> >    Cyclomatic Complexity 3 fs/dcache.c:d_shrink_del
> >    Cyclomatic Complexity 5 fs/dcache.c:path_check_mount
> >    Cyclomatic Complexity 3 fs/dcache.c:d_shrink_add
> >    Cyclomatic Complexity 29 fs/dcache.c:d_set_d_op
> >    Cyclomatic Complexity 19 fs/dcache.c:d_flags_for_inode
> >    Cyclomatic Complexity 6 fs/dcache.c:__d_instantiate
> >    Cyclomatic Complexity 3 fs/dcache.c:take_dentry_name_snapshot
> >    Cyclomatic Complexity 8 fs/dcache.c:swap_names
> >    Cyclomatic Complexity 5 fs/dcache.c:release_dentry_name_snapshot
> >    Cyclomatic Complexity 8 fs/dcache.c:copy_name
> >    Cyclomatic Complexity 7 fs/dcache.c:d_lru_add
> >    Cyclomatic Complexity 7 fs/dcache.c:d_lru_del
> >    Cyclomatic Complexity 16 fs/dcache.c:select_collect
> >    Cyclomatic Complexity 12 fs/dcache.c:dentry_unlink_inode
> >    Cyclomatic Complexity 1 fs/dcache.c:__d_free_external
> >    Cyclomatic Complexity 1 fs/dcache.c:__d_free
> >    Cyclomatic Complexity 10 fs/dcache.c:dentry_free
> >    Cyclomatic Complexity 32 fs/dcache.c:__dentry_kill
> >    Cyclomatic Complexity 28 fs/dcache.c:dentry_kill
> >    Cyclomatic Complexity 6 fs/dcache.c:dput
> >    Cyclomatic Complexity 12 fs/dcache.c:d_prune_aliases
> >    Cyclomatic Complexity 15 fs/dcache.c:shrink_dentry_list
> >    Cyclomatic Complexity 2 fs/dcache.c:shrink_dcache_sb
> >    Cyclomatic Complexity 8 fs/dcache.c:dget_parent
> >    Cyclomatic Complexity 5 fs/dcache.c:d_lru_isolate
> >    Cyclomatic Complexity 5 fs/dcache.c:d_lru_shrink_move
> >    Cyclomatic Complexity 9 fs/dcache.c:dentry_lru_isolate
> >    Cyclomatic Complexity 3 fs/dcache.c:dentry_lru_isolate_shrink
> >    Cyclomatic Complexity 26 fs/dcache.c:d_walk
> >    Cyclomatic Complexity 1 fs/dcache.c:path_has_submounts
> >    Cyclomatic Complexity 6 fs/dcache.c:shrink_dcache_parent
> >    Cyclomatic Complexity 1 fs/dcache.c:do_one_tree
> >    Cyclomatic Complexity 12 fs/dcache.c:d_invalidate
> >    Cyclomatic Complexity 1 fs/dcache.c:d_genocide
> >    Cyclomatic Complexity 14 fs/dcache.c:umount_check
> >    Cyclomatic Complexity 5 fs/dcache.c:d_instantiate
> >    Cyclomatic Complexity 10 fs/dcache.c:__d_instantiate_anon
> >    Cyclomatic Complexity 1 fs/dcache.c:d_instantiate_anon
> >    Cyclomatic Complexity 4 fs/dcache.c:d_add
> >    Cyclomatic Complexity 5 fs/dcache.c:d_instantiate_new
> >    Cyclomatic Complexity 4 fs/dcache.c:d_delete
> >    Cyclomatic Complexity 6 fs/dcache.c:d_wait_lookup
> >    Cyclomatic Complexity 1 fs/dcache.c:__d_lookup_done
> >    Cyclomatic Complexity 6 fs/dcache.c:d_tmpfile
> >    Cyclomatic Complexity 4 fs/dcache.c:set_dhash_entries
> >    Cyclomatic Complexity 2 fs/dcache.c:vfs_caches_init_early
> >    Cyclomatic Complexity 1 fs/dcache.c:vfs_caches_init
> >    Cyclomatic Complexity 1 fs/dcache.c:proc_nr_dentry
> >    Cyclomatic Complexity 1 fs/dcache.c:prune_dcache_sb
> >    Cyclomatic Complexity 8 fs/dcache.c:d_set_mounted
> >    Cyclomatic Complexity 4 fs/dcache.c:shrink_dcache_for_umount
> >    Cyclomatic Complexity 25 fs/dcache.c:__d_alloc
> >    Cyclomatic Complexity 4 fs/dcache.c:d_alloc
> >    Cyclomatic Complexity 1 fs/dcache.c:d_alloc_name
> >    Cyclomatic Complexity 1 fs/dcache.c:d_alloc_anon
> >    Cyclomatic Complexity 7 fs/dcache.c:d_make_root
> >    Cyclomatic Complexity 12 fs/dcache.c:__d_obtain_alias
> >    Cyclomatic Complexity 1 fs/dcache.c:d_obtain_alias
> >    Cyclomatic Complexity 1 fs/dcache.c:d_obtain_root
> >    Cyclomatic Complexity 4 fs/dcache.c:d_alloc_cursor
> >    Cyclomatic Complexity 3 fs/dcache.c:d_alloc_pseudo
> >    Cyclomatic Complexity 22 fs/dcache.c:__d_lookup_rcu
> >    Cyclomatic Complexity 35 fs/dcache.c:d_alloc_parallel
> >    Cyclomatic Complexity 13 fs/dcache.c:__d_lookup
> >    Cyclomatic Complexity 5 fs/dcache.c:d_lookup
> >    Cyclomatic Complexity 6 fs/dcache.c:d_hash_and_lookup
> >    Cyclomatic Complexity 5 fs/dcache.c:d_ancestor
> >    Cyclomatic Complexity 42 fs/dcache.c:__d_move
> >    Cyclomatic Complexity 1 fs/dcache.c:d_move
> >    Cyclomatic Complexity 9 fs/dcache.c:d_exchange
> >    Cyclomatic Complexity 14 fs/dcache.c:__d_unalias
> >    Cyclomatic Complexity 22 fs/dcache.c:d_splice_alias
> >    Cyclomatic Complexity 15 fs/dcache.c:d_add_ci
> >    Cyclomatic Complexity 7 fs/dcache.c:is_subdir
> >    In file included from include/linux/compiler.h:252:0,
> >                     from arch/x86/include/asm/current.h:5,
> >                     from include/linux/sched.h:12,
> >                     from include/linux/ratelimit.h:6,
> >                     from fs/dcache.c:18:
> >    include/linux/compiler.h: In function 'read_word_at_a_time':
> > > > include/linux/kasan-checks.h:25:20: error: inlining failed in call =
to
> > > > always_inline 'kasan_check_read': function attribute mismatch
> >
> >     static inline void kasan_check_read(const volatile void *p, unsigne=
d int
> > size)
> >                        ^~~~~~~~~~~~~~~~
> >    In file included from arch/x86/include/asm/current.h:5:0,
> >                     from include/linux/sched.h:12,
> >                     from include/linux/ratelimit.h:6,
> >                     from fs/dcache.c:18:
> >    include/linux/compiler.h:275:2: note: called from here
> >      kasan_check_read(addr, 1);
> >      ^~~~~~~~~~~~~~~~~~~~~~~~~
> > --
> >    Cyclomatic Complexity 1 include/linux/kasan-checks.h:kasan_check_rea=
d
> >    Cyclomatic Complexity 1 include/linux/compiler.h:read_word_at_a_time
> >    Cyclomatic Complexity 4 include/linux/ctype.h:__tolower
> >    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> > time.h:count_masked_bytes
> >    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-time.h:has_ze=
ro
> >    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> > time.h:prep_zero_mask
> >    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-
> > time.h:create_zero_mask
> >    Cyclomatic Complexity 1 arch/x86/include/asm/word-at-a-time.h:find_z=
ero
> >    Cyclomatic Complexity 2 lib/string.c:strcasecmp
> >    Cyclomatic Complexity 2 lib/string.c:strcpy
> >    Cyclomatic Complexity 4 lib/string.c:strncpy
> >    Cyclomatic Complexity 3 lib/string.c:strcat
> >    Cyclomatic Complexity 3 lib/string.c:strchrnul
> >    Cyclomatic Complexity 2 lib/string.c:skip_spaces
> >    Cyclomatic Complexity 2 lib/string.c:strlen
> >    Cyclomatic Complexity 3 lib/string.c:strnlen
> >    Cyclomatic Complexity 4 lib/string.c:memcmp
> >    Cyclomatic Complexity 1 lib/string.c:bcmp
> >    Cyclomatic Complexity 4 lib/string.c:memchr
> >    Cyclomatic Complexity 14 lib/string.c:strncasecmp
> >    Cyclomatic Complexity 20 lib/string.c:strscpy
> >    Cyclomatic Complexity 8 lib/string.c:strncat
> >    Cyclomatic Complexity 8 lib/string.c:strcmp
> >    Cyclomatic Complexity 9 lib/string.c:strncmp
> >    Cyclomatic Complexity 5 lib/string.c:strchr
> >    Cyclomatic Complexity 5 lib/string.c:strrchr
> >    Cyclomatic Complexity 6 lib/string.c:strnchr
> >    Cyclomatic Complexity 6 lib/string.c:strim
> >    Cyclomatic Complexity 9 lib/string.c:strspn
> >    Cyclomatic Complexity 6 lib/string.c:strcspn
> >    Cyclomatic Complexity 6 lib/string.c:strpbrk
> >    Cyclomatic Complexity 7 lib/string.c:strsep
> >    Cyclomatic Complexity 28 lib/string.c:sysfs_streq
> >    Cyclomatic Complexity 8 lib/string.c:match_string
> >    Cyclomatic Complexity 7 lib/string.c:__sysfs_match_string
> >    Cyclomatic Complexity 5 lib/string.c:memscan
> >    Cyclomatic Complexity 8 lib/string.c:strstr
> >    Cyclomatic Complexity 8 lib/string.c:strnstr
> >    Cyclomatic Complexity 5 lib/string.c:check_bytes8
> >    Cyclomatic Complexity 14 lib/string.c:memchr_inv
> >    Cyclomatic Complexity 5 lib/string.c:strreplace
> >    Cyclomatic Complexity 5 lib/string.c:strlcpy
> >    Cyclomatic Complexity 9 lib/string.c:strscpy_pad
> >    Cyclomatic Complexity 1 lib/string.c:memzero_explicit
> >    Cyclomatic Complexity 5 lib/string.c:strlcat
> >    Cyclomatic Complexity 0 lib/string.c:fortify_panic
> >    In file included from include/linux/compiler.h:252:0,
> >                     from include/linux/string.h:6,
> >                     from lib/string.c:24:
> >    include/linux/compiler.h: In function 'read_word_at_a_time':
> > > > include/linux/kasan-checks.h:25:20: error: inlining failed in call =
to
> > > > always_inline 'kasan_check_read': function attribute mismatch
> >
> >     static inline void kasan_check_read(const volatile void *p, unsigne=
d int
> > size)
> >                        ^~~~~~~~~~~~~~~~
> >    In file included from include/linux/string.h:6:0,
> >                     from lib/string.c:24:
> >    include/linux/compiler.h:275:2: note: called from here
> >      kasan_check_read(addr, 1);
> >      ^~~~~~~~~~~~~~~~~~~~~~~~~
> >
> > vim +/kasan_check_read +25 include/linux/kasan-checks.h
> >
> >     19
> >     20        /*
> >     21         * kasan_check_*: Only available when the particular comp=
ilation
> > unit has KASAN
> >     22         * instrumentation enabled. May be used in header files.
> >     23         */
> >     24        #ifdef __SANITIZE_ADDRESS__
> >   > 25        static inline void kasan_check_read(const volatile void *=
p,
> > unsigned int size)
> >     26        {
> >     27                __kasan_check_read(p, size);
> >     28        }
> >     29        static inline void kasan_check_write(const volatile void =
*p,
> > unsigned int size)
> >     30        {
> >     31                __kasan_check_read(p, size);
> >     32        }
> >     33        #else
> >     34        static inline void kasan_check_read(const volatile void *=
p,
> > unsigned int size)
> >     35        { }
> >     36        static inline void kasan_check_write(const volatile void =
*p,
> > unsigned int size)
> >     37        { }
> >     38        #endif
> >     39
> >
> > ---
> > 0-DAY kernel test infrastructure                Open Source Technology =
Center
> > https://lists.01.org/pipermail/kbuild-all                   Intel Corpo=
ration

