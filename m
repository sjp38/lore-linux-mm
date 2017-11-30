Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 387986B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:23:03 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id p5so6707388iop.14
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:23:03 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e76sor2308857ioe.104.2017.11.30.11.23.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 11:23:01 -0800 (PST)
Date: Thu, 30 Nov 2017 13:22:57 -0600
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [pcpu] BUG: KASAN: use-after-scope in
 pcpu_setup_first_chunk+0x1e3b/0x29e2
Message-ID: <20171130192257.GB1529@localhost>
References: <20171126063117.oytmra3tqoj5546u@wfg-t540p.sh.intel.com>
 <20171127210301.GA55812@localhost.corp.microsoft.com>
 <20171128124534.3jvuala525wvn64r@wfg-t540p.sh.intel.com>
 <20171129175430.GA58181@big-sky.attlocal.net>
 <CACT4Y+bji1JMJVJZdv=+bD8JZ1kqrmJ0PWXvHdYzRFcnAKDSGw@mail.gmail.com>
 <CAGXu5jLOojG_Nc50KhdHsXDQQ27G+kOPp6-5kQz7Yh5Vpgucnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLOojG_Nc50KhdHsXDQQ27G+kOPp6-5kQz7Yh5Vpgucnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Linux-MM <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>

Hi Dmitry and Kees,

On Thu, Nov 30, 2017 at 10:10:41AM -0800, Kees Cook wrote:
> > Are we sure that structleak plugin is not at fault? If yes, then we
> > need to report this to https://gcc.gnu.org/bugzilla/ with instructions
> > on how to build/use the plugin.

I believe this is an issue with the structleak plugin and not gcc. The
bug does not show up if you compile without
GCC_PLUGIN_STRUCTLEAK_BYREF_ALL.

It seems to be caused by the initializer not respecting the ASAN_MARK
calls. Therefore, if an inlined function gets called from a for loop,
the initializer code gets invoked bugging in the second iteration. Below
is the tree dump for the structleak plugin from the reproducer in the
previous email. In bb 2 of INIT_LIST_HEAD, the __u = {} is before the
unpoison call. This is inlined in bb 3 of main.

> 
> I thought from earlier in this thread that the bug just changed
> locations depending on the plugin. Does the issue still exist with the
> plugin disabled?
> 

The bug changing locations was me just verifying it was not an issue
with percpu memory. I manually unrolled the for loop to show that the
percpu bug disappears, but manifests later on. The issue does not exist
with the BY_REF_ALL config.

Thanks,
Dennis

----

;; Function __write_once_size (__write_once_size, funcdef_no=2, decl_uid=3117, cgraph_uid=2, symbol_order=2)

__attribute__((always_inline))
__write_once_size (volatile void * p, void * res, int size)
{
  unsigned char _1;
  short unsigned int _2;
  unsigned int _3;
  long unsigned int _4;
  long unsigned int _5;

  <bb 2> [0.00%]:
  switch (size_7(D)) <default: <L4> [0.00%], case 1: <L0> [0.00%], case 2: <L1> [0.00%], case 4: <L2> [0.00%], case 8: <L3> [0.00%]>

<L0> [0.00%]:
  _1 = MEM[(__u8 *)res_9(D)];
  MEM[(volatile __u8 *)p_10(D)] ={v} _1;
  goto <bb 8>; [0.00%]

<L1> [0.00%]:
  _2 = MEM[(__u16 *)res_9(D)];
  MEM[(volatile __u16 *)p_10(D)] ={v} _2;
  goto <bb 8>; [0.00%]

<L2> [0.00%]:
  _3 = MEM[(__u32 *)res_9(D)];
  MEM[(volatile __u32 *)p_10(D)] ={v} _3;
  goto <bb 8>; [0.00%]

<L3> [0.00%]:
  _4 = MEM[(__u64 *)res_9(D)];
  MEM[(volatile __u64 *)p_10(D)] ={v} _4;
  goto <bb 8>; [0.00%]

<L4> [0.00%]:
  _5 = (long unsigned int) size_7(D);
  __builtin_memcpy (p_10(D), res_9(D), _5);

  <bb 8> [0.00%]:
  return;

}



;; Function INIT_LIST_HEAD (INIT_LIST_HEAD, funcdef_no=3, decl_uid=3129, cgraph_uid=3, symbol_order=3)


Symbols to be put in SSA form
{ D.3149 }
Incremental SSA update started at block: 0
Number of blocks in CFG: 9
Number of blocks to update: 8 ( 89%)


__attribute__((always_inline))
INIT_LIST_HEAD (struct list_head * list)
{
  volatile void * p;
  void * res;
  int size;
  union 
  {
    struct list_head * __val;
    char __c[1];
  } __u;
  struct list_head * D.3135;
  struct list_head * * _1;
  struct list_head * _7;
  unsigned char _13;
  short unsigned int _14;
  unsigned int _15;
  long unsigned int _16;
  long unsigned int _17;

  <bb 2> [0.00%]:
  __u = {};
  ASAN_MARK (UNPOISON, &__u, 8);
  __u.__val = list_4(D);
  _1 = &list_4(D)->next;
  p_10 = _1;
  res_11 = &__u.__c;
  size_12 = 8;
  switch (size_12) <default: <L4> [0.00%], case 1: <L0> [0.00%], case 2: <L1> [0.00%], case 4: <L2> [0.00%], case 8: <L3> [0.00%]>

<L0> [0.00%]:
  _13 = MEM[(__u8 *)res_11];
  MEM[(volatile __u8 *)p_10] ={v} _13;
  goto <bb 8>; [0.00%]

<L1> [0.00%]:
  _14 = MEM[(__u16 *)res_11];
  MEM[(volatile __u16 *)p_10] ={v} _14;
  goto <bb 8>; [0.00%]

<L2> [0.00%]:
  _15 = MEM[(__u32 *)res_11];
  MEM[(volatile __u32 *)p_10] ={v} _15;
  goto <bb 8>; [0.00%]

<L3> [0.00%]:
  _16 = MEM[(__u64 *)res_11];
  MEM[(volatile __u64 *)p_10] ={v} _16;
  goto <bb 8>; [0.00%]

<L4> [0.00%]:
  _17 = (long unsigned int) size_12;
  __builtin_memcpy (p_10, res_11, _17);

  <bb 8> [0.00%]:
  _7 = __u.__val;
  ASAN_MARK (POISON, &__u, 8);
  list_4(D)->prev = list_4(D);
  return;

}



;; Function main (main, funcdef_no=4, decl_uid=3138, cgraph_uid=4, symbol_order=4)


Symbols to be put in SSA form
{ D.3150 }
Incremental SSA update started at block: 0
Number of blocks in CFG: 13
Number of blocks to update: 12 ( 92%)


main (int argc, char * * argv)
{
  struct list_head * D.3165;
  union 
  {
    struct list_head * __val;
    char __c[1];
  } __u;
  int size;
  void * res;
  volatile void * p;
  struct list_head * list;
  int i;
  struct list_head * p;
  int D.3146;
  long unsigned int _1;
  long unsigned int _2;
  struct list_head * _3;
  int _11;
  struct list_head * * _15;
  unsigned char _19;
  short unsigned int _20;
  unsigned int _21;
  long unsigned int _22;
  long unsigned int _23;
  struct list_head * _24;

  <bb 2> [0.00%]:
  __u = {};
  p_8 = malloc (160);
  i_9 = 0;
  goto <bb 10>; [0.00%]

  <bb 3> [0.00%]:
  _1 = (long unsigned int) i_4;
  _2 = _1 * 16;
  _3 = p_8 + _2;
  list_14 = _3;
  __u = {};
  ASAN_MARK (UNPOISON, &__u, 8);
  __u.__val = list_14;
  _15 = &list_14->next;
  p_16 = _15;
  res_17 = &__u.__c;
  size_18 = 8;
  switch (size_18) <default: <L8> [0.00%], case 1: <L4> [0.00%], case 2: <L5> [0.00%], case 4: <L6> [0.00%], case 8: <L7> [0.00%]>

<L4> [0.00%]:
  _19 = MEM[(__u8 *)res_17];
  MEM[(volatile __u8 *)p_16] ={v} _19;
  goto <bb 9>; [0.00%]

<L5> [0.00%]:
  _20 = MEM[(__u16 *)res_17];
  MEM[(volatile __u16 *)p_16] ={v} _20;
  goto <bb 9>; [0.00%]

<L6> [0.00%]:
  _21 = MEM[(__u32 *)res_17];
  MEM[(volatile __u32 *)p_16] ={v} _21;
  goto <bb 9>; [0.00%]

<L7> [0.00%]:
  _22 = MEM[(__u64 *)res_17];
  MEM[(volatile __u64 *)p_16] ={v} _22;
  goto <bb 9>; [0.00%]

<L8> [0.00%]:
  _23 = (long unsigned int) size_18;
  __builtin_memcpy (p_16, res_17, _23);

  <bb 9> [0.00%]:
  _24 = __u.__val;
  ASAN_MARK (POISON, &__u, 8);
  list_14->prev = list_14;
  i_13 = i_4 + 1;

  <bb 10> [0.00%]:
  # i_4 = PHI <i_9(2), i_13(9)>
  if (i_4 <= 9)
    goto <bb 3>; [0.00%]
  else
    goto <bb 11>; [0.00%]

  <bb 11> [0.00%]:
  free (p_8);
  _11 = 0;

<L3> [0.00%]:
  return _11;

}



;; Function _GLOBAL__sub_I_00099_0_main (_GLOBAL__sub_I_00099_0_main, funcdef_no=5, decl_uid=3178, cgraph_uid=3, symbol_order=8)

_GLOBAL__sub_I_00099_0_main ()
{
  <bb 2> [0.00%]:
  __builtin___asan_init ();
  __builtin___asan_version_mismatch_check_v8 ();
  return;

}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
