Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0FF46B0007
	for <linux-mm@kvack.org>; Thu, 21 Jun 2018 08:40:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x14-v6so2387057ioa.6
        for <linux-mm@kvack.org>; Thu, 21 Jun 2018 05:40:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r127-v6sor1901735jar.121.2018.06.21.05.40.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Jun 2018 05:40:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201806210451.tOaA22Qm%fengguang.wu@intel.com>
References: <687f2c3ce27015abb6bc412646894ae40051d8af.1529515183.git.andreyknvl@google.com>
 <201806210451.tOaA22Qm%fengguang.wu@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 21 Jun 2018 14:40:42 +0200
Message-ID: <CAAeHK+zsYPRqGTOZxt_wdd3vnOFWPO4viv2_tbhbCFTCJCNf4Q@mail.gmail.com>
Subject: Re: [PATCH v3 02/17] khwasan: move common kasan and khwasan code to common.c
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Wed, Jun 20, 2018 at 10:36 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Andrey,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on mmotm/master]
> [also build test ERROR on v4.18-rc1 next-20180620]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Andrey-Konovalov/khwasan-kernel-hardware-assisted-address-sanitizer/20180621-035912
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: x86_64-randconfig-x011-201824 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> Note: the linux-review/Andrey-Konovalov/khwasan-kernel-hardware-assisted-address-sanitizer/20180621-035912 HEAD 0e30ed7118e854b38bb6ab96365e7c74a2518290 builds fine.
>       It only hurts bisectibility.

Will fix in v4, thanks!

>
> All errors (new ones prefixed by >>):
>
>>> mm//kasan/report.c:42:20: error: conflicting types for 'find_first_bad_addr'
>     static const void *find_first_bad_addr(const void *addr, size_t size)
>                        ^~~~~~~~~~~~~~~~~~~
>    In file included from mm//kasan/report.c:33:0:
>    mm//kasan/kasan.h:130:7: note: previous declaration of 'find_first_bad_addr' was here
>     void *find_first_bad_addr(void *addr, size_t size);
>           ^~~~~~~~~~~~~~~~~~~
>>> mm//kasan/report.c:54:13: error: conflicting types for 'addr_has_shadow'
>     static bool addr_has_shadow(struct kasan_access_info *info)
>                 ^~~~~~~~~~~~~~~
>    In file included from mm//kasan/report.c:33:0:
>    mm//kasan/kasan.h:120:20: note: previous definition of 'addr_has_shadow' was here
>     static inline bool addr_has_shadow(const void *addr)
>                        ^~~~~~~~~~~~~~~
>    mm//kasan/report.c: In function 'get_shadow_bug_type':
>    mm//kasan/report.c:86:2: error: duplicate case value
>      case KASAN_KMALLOC_REDZONE:
>      ^~~~
>    mm//kasan/report.c:85:2: note: previously used here
>      case KASAN_PAGE_REDZONE:
>      ^~~~
>    mm//kasan/report.c:98:2: error: duplicate case value
>      case KASAN_FREE_PAGE:
>      ^~~~
>    mm//kasan/report.c:85:2: note: previously used here
>      case KASAN_PAGE_REDZONE:
>      ^~~~
>    mm//kasan/report.c:99:2: error: duplicate case value
>      case KASAN_KMALLOC_FREE:
>      ^~~~
>    mm//kasan/report.c:85:2: note: previously used here
>      case KASAN_PAGE_REDZONE:
>      ^~~~
>    mm//kasan/report.c: At top level:
>>> mm//kasan/report.c:128:20: error: static declaration of 'get_bug_type' follows non-static declaration
>     static const char *get_bug_type(struct kasan_access_info *info)
>                        ^~~~~~~~~~~~
>    In file included from mm//kasan/report.c:33:0:
>    mm//kasan/kasan.h:131:13: note: previous declaration of 'get_bug_type' was here
>     const char *get_bug_type(struct kasan_access_info *info);
>                 ^~~~~~~~~~~~
>
> vim +/find_first_bad_addr +42 mm//kasan/report.c
>
> 0b24becc Andrey Ryabinin  2015-02-13   41
> 0b24becc Andrey Ryabinin  2015-02-13  @42  static const void *find_first_bad_addr(const void *addr, size_t size)
> 0b24becc Andrey Ryabinin  2015-02-13   43  {
> 0b24becc Andrey Ryabinin  2015-02-13   44       u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
> 0b24becc Andrey Ryabinin  2015-02-13   45       const void *first_bad_addr = addr;
> 0b24becc Andrey Ryabinin  2015-02-13   46
> 0b24becc Andrey Ryabinin  2015-02-13   47       while (!shadow_val && first_bad_addr < addr + size) {
> 0b24becc Andrey Ryabinin  2015-02-13   48               first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
> 0b24becc Andrey Ryabinin  2015-02-13   49               shadow_val = *(u8 *)kasan_mem_to_shadow(first_bad_addr);
> 0b24becc Andrey Ryabinin  2015-02-13   50       }
> 0b24becc Andrey Ryabinin  2015-02-13   51       return first_bad_addr;
> 0b24becc Andrey Ryabinin  2015-02-13   52  }
> 0b24becc Andrey Ryabinin  2015-02-13   53
> 5e82cd12 Andrey Konovalov 2017-05-03  @54  static bool addr_has_shadow(struct kasan_access_info *info)
> 5e82cd12 Andrey Konovalov 2017-05-03   55  {
> 5e82cd12 Andrey Konovalov 2017-05-03   56       return (info->access_addr >=
> 5e82cd12 Andrey Konovalov 2017-05-03   57               kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
> 5e82cd12 Andrey Konovalov 2017-05-03   58  }
> 5e82cd12 Andrey Konovalov 2017-05-03   59
> 5e82cd12 Andrey Konovalov 2017-05-03   60  static const char *get_shadow_bug_type(struct kasan_access_info *info)
> 0b24becc Andrey Ryabinin  2015-02-13   61  {
> 0952d87f Andrey Konovalov 2015-11-05   62       const char *bug_type = "unknown-crash";
> cdf6a273 Andrey Konovalov 2015-11-05   63       u8 *shadow_addr;
> 0b24becc Andrey Ryabinin  2015-02-13   64
> 0b24becc Andrey Ryabinin  2015-02-13   65       info->first_bad_addr = find_first_bad_addr(info->access_addr,
> 0b24becc Andrey Ryabinin  2015-02-13   66                                               info->access_size);
> 0b24becc Andrey Ryabinin  2015-02-13   67
> cdf6a273 Andrey Konovalov 2015-11-05   68       shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
> 0b24becc Andrey Ryabinin  2015-02-13   69
> cdf6a273 Andrey Konovalov 2015-11-05   70       /*
> cdf6a273 Andrey Konovalov 2015-11-05   71        * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
> cdf6a273 Andrey Konovalov 2015-11-05   72        * at the next shadow byte to determine the type of the bad access.
> cdf6a273 Andrey Konovalov 2015-11-05   73        */
> cdf6a273 Andrey Konovalov 2015-11-05   74       if (*shadow_addr > 0 && *shadow_addr <= KASAN_SHADOW_SCALE_SIZE - 1)
> cdf6a273 Andrey Konovalov 2015-11-05   75               shadow_addr++;
> cdf6a273 Andrey Konovalov 2015-11-05   76
> cdf6a273 Andrey Konovalov 2015-11-05   77       switch (*shadow_addr) {
> 0952d87f Andrey Konovalov 2015-11-05   78       case 0 ... KASAN_SHADOW_SCALE_SIZE - 1:
> cdf6a273 Andrey Konovalov 2015-11-05   79               /*
> cdf6a273 Andrey Konovalov 2015-11-05   80                * In theory it's still possible to see these shadow values
> cdf6a273 Andrey Konovalov 2015-11-05   81                * due to a data race in the kernel code.
> cdf6a273 Andrey Konovalov 2015-11-05   82                */
> 0952d87f Andrey Konovalov 2015-11-05   83               bug_type = "out-of-bounds";
> b8c73fc2 Andrey Ryabinin  2015-02-13   84               break;
> 0316bec2 Andrey Ryabinin  2015-02-13   85       case KASAN_PAGE_REDZONE:
> 0316bec2 Andrey Ryabinin  2015-02-13   86       case KASAN_KMALLOC_REDZONE:
> 0952d87f Andrey Konovalov 2015-11-05   87               bug_type = "slab-out-of-bounds";
> 0952d87f Andrey Konovalov 2015-11-05   88               break;
> bebf56a1 Andrey Ryabinin  2015-02-13   89       case KASAN_GLOBAL_REDZONE:
> 0952d87f Andrey Konovalov 2015-11-05   90               bug_type = "global-out-of-bounds";
> 0b24becc Andrey Ryabinin  2015-02-13   91               break;
> c420f167 Andrey Ryabinin  2015-02-13   92       case KASAN_STACK_LEFT:
> c420f167 Andrey Ryabinin  2015-02-13   93       case KASAN_STACK_MID:
> c420f167 Andrey Ryabinin  2015-02-13   94       case KASAN_STACK_RIGHT:
> c420f167 Andrey Ryabinin  2015-02-13   95       case KASAN_STACK_PARTIAL:
> 0952d87f Andrey Konovalov 2015-11-05   96               bug_type = "stack-out-of-bounds";
> 0952d87f Andrey Konovalov 2015-11-05   97               break;
> 0952d87f Andrey Konovalov 2015-11-05   98       case KASAN_FREE_PAGE:
> 0952d87f Andrey Konovalov 2015-11-05  @99       case KASAN_KMALLOC_FREE:
> 0952d87f Andrey Konovalov 2015-11-05  100               bug_type = "use-after-free";
> c420f167 Andrey Ryabinin  2015-02-13  101               break;
> 828347f8 Dmitry Vyukov    2016-11-30  102       case KASAN_USE_AFTER_SCOPE:
> 828347f8 Dmitry Vyukov    2016-11-30  103               bug_type = "use-after-scope";
> 828347f8 Dmitry Vyukov    2016-11-30  104               break;
> 342061ee Paul Lawrence    2018-02-06  105       case KASAN_ALLOCA_LEFT:
> 342061ee Paul Lawrence    2018-02-06  106       case KASAN_ALLOCA_RIGHT:
> 342061ee Paul Lawrence    2018-02-06  107               bug_type = "alloca-out-of-bounds";
> 342061ee Paul Lawrence    2018-02-06  108               break;
> 0b24becc Andrey Ryabinin  2015-02-13  109       }
> 0b24becc Andrey Ryabinin  2015-02-13  110
> 5e82cd12 Andrey Konovalov 2017-05-03  111       return bug_type;
> 5e82cd12 Andrey Konovalov 2017-05-03  112  }
> 5e82cd12 Andrey Konovalov 2017-05-03  113
> 822d5ec2 Colin Ian King   2017-07-10  114  static const char *get_wild_bug_type(struct kasan_access_info *info)
> 5e82cd12 Andrey Konovalov 2017-05-03  115  {
> 5e82cd12 Andrey Konovalov 2017-05-03  116       const char *bug_type = "unknown-crash";
> 5e82cd12 Andrey Konovalov 2017-05-03  117
> 5e82cd12 Andrey Konovalov 2017-05-03  118       if ((unsigned long)info->access_addr < PAGE_SIZE)
> 5e82cd12 Andrey Konovalov 2017-05-03  119               bug_type = "null-ptr-deref";
> 5e82cd12 Andrey Konovalov 2017-05-03  120       else if ((unsigned long)info->access_addr < TASK_SIZE)
> 5e82cd12 Andrey Konovalov 2017-05-03  121               bug_type = "user-memory-access";
> 5e82cd12 Andrey Konovalov 2017-05-03  122       else
> 5e82cd12 Andrey Konovalov 2017-05-03  123               bug_type = "wild-memory-access";
> 5e82cd12 Andrey Konovalov 2017-05-03  124
> 5e82cd12 Andrey Konovalov 2017-05-03  125       return bug_type;
> 5e82cd12 Andrey Konovalov 2017-05-03  126  }
> 5e82cd12 Andrey Konovalov 2017-05-03  127
> 7d418f7b Andrey Konovalov 2017-05-03 @128  static const char *get_bug_type(struct kasan_access_info *info)
> 7d418f7b Andrey Konovalov 2017-05-03  129  {
> 7d418f7b Andrey Konovalov 2017-05-03  130       if (addr_has_shadow(info))
> 7d418f7b Andrey Konovalov 2017-05-03  131               return get_shadow_bug_type(info);
> 7d418f7b Andrey Konovalov 2017-05-03  132       return get_wild_bug_type(info);
> 7d418f7b Andrey Konovalov 2017-05-03  133  }
> 7d418f7b Andrey Konovalov 2017-05-03  134
>
> :::::: The code at line 42 was first introduced by commit
> :::::: 0b24becc810dc3be6e3f94103a866f214c282394 kasan: add kernel address sanitizer infrastructure
>
> :::::: TO: Andrey Ryabinin <a.ryabinin@samsung.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/201806210451.tOaA22Qm%25fengguang.wu%40intel.com.
> For more options, visit https://groups.google.com/d/optout.
