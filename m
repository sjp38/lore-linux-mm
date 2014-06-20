Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE4E6B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 11:20:06 -0400 (EDT)
Received: by mail-wg0-f41.google.com with SMTP id a1so3794897wgh.0
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:19:59 -0700 (PDT)
Received: from mail-we0-x22e.google.com (mail-we0-x22e.google.com [2a00:1450:400c:c03::22e])
        by mx.google.com with ESMTPS id y6si7044576wjx.170.2014.06.20.08.19.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 08:19:59 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id u57so3951785wes.19
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 08:19:58 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [mmotm:master 141/230] include/linux/kernel.h:744:28: note: in expansion of macro 'min'
In-Reply-To: <20140620055210.GA26552@localhost>
References: <53a3c359.yUYVC7fzjYpZLyLq%fengguang.wu@intel.com> <20140620055210.GA26552@localhost>
Date: Fri, 20 Jun 2014 17:19:55 +0200
Message-ID: <xa1tppi3vc9w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Hagen Paul Pfeifer <hagen@jauu.net>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Fri, Jun 20 2014, Fengguang Wu <fengguang.wu@intel.com> wrote:
>>> include/linux/kernel.h:744:28: note: in expansion of macro 'min'
>     #define clamp(val, lo, hi) min(max(val, lo), hi)
>                                ^
>>> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:1901:11: note: in expans=
ion of macro 'clamp'
>       bytes =3D clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
>               ^

The obvious fix:

----------- >8 ------------------------------------------------------------=
--
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 44649e0..149864b 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -719,8 +719,8 @@ static inline void ftrace_dump(enum ftrace_dump_mode oo=
ps_dump_mode) { }
        (void) (&_max1 =3D=3D &_max2);              \
        _max1 > _max2 ? _max1 : _max2; })
=20
-#define min3(x, y, z) min(min(x, y), z)
-#define max3(x, y, z) max(max(x, y), z)
+#define min3(x, y, z) min((typeof(x))min(x, y), z)
+#define max3(x, y, z) max((typeof(x))max(x, y), z)
=20
 /**
  * min_not_zero - return the minimum that is _not_ zero, unless both are z=
ero
@@ -741,7 +741,7 @@ static inline void ftrace_dump(enum ftrace_dump_mode oo=
ps_dump_mode) { }
  * This macro does strict typechecking of min/max to make sure they are of=
 the
  * same type as val.  See the unnecessary pointer comparisons.
  */
-#define clamp(val, lo, hi) min(max(val, lo), hi)
+#define clamp(val, lo, hi) min((typeof(val))max(val, lo), hi)
=20
 /*
  * ..and if you can't take the strict
----------- >8 ------------------------------------------------------------=
--

increases size of the kernel:

-rwx------ 1 mpn eng 437026785 Jun 20 15:45 vmlinux.before
-rwx------ 1 mpn eng 437026881 Jun 20 15:30 vmlinux.after

even though it's still slightly smaller than w/o the patch all together:

-rwx------ 1 mpn eng 437027411 Jun 20 16:04 vmlinux.before.before

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
