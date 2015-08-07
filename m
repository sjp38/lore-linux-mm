Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 07E2F6B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 15:02:55 -0400 (EDT)
Received: by ioeg141 with SMTP id g141so120512198ioe.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 12:02:54 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id j124si8911780ioe.170.2015.08.07.12.02.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 12:02:54 -0700 (PDT)
Received: by iodb91 with SMTP id b91so60640455iod.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 12:02:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201508070924.YNOeybcV%fengguang.wu@intel.com>
References: <201508070924.YNOeybcV%fengguang.wu@intel.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 7 Aug 2015 15:02:34 -0400
Message-ID: <CALZtONBF7UbyFO5VD3RH4G58_WJb+4bQSiGKZoKgbka19eGXXg@mail.gmail.com>
Subject: Re: [linux-next:master 6299/6518] mm/zswap.c:759:1: warning:
 '__zswap_param_set' uses dynamic stack allocation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Aug 6, 2015 at 9:59 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   c6b169e6ffb962068153bd92b0c4ecbd731a122f
> commit: e2e60954eae9929a982d12b6ff24a91b37822f34 [6299/6518] zswap: change zpool/compressor at runtime
> config: s390-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout e2e60954eae9929a982d12b6ff24a91b37822f34
>   # save the attached .config to linux build tree
>   make.cross ARCH=s390
>
> All warnings (new ones prefixed by >>):
>
>    mm/zswap.c: In function '__zswap_param_set':
>>> mm/zswap.c:759:1: warning: '__zswap_param_set' uses dynamic stack allocation

ugh, ok.  It really should be fine, but I'll send a patch to use a
static-sized array instead; we know it's never more than 64 bytes.


>     }
>     ^
>
> vim +/__zswap_param_set +759 mm/zswap.c
>
>    743                   * list; if it's new (and empty) then it'll be removed and
>    744                   * destroyed by the put after we drop the lock
>    745                   */
>    746                  list_add_tail_rcu(&pool->list, &zswap_pools);
>    747                  put_pool = pool;
>    748          }
>    749
>    750          spin_unlock(&zswap_pools_lock);
>    751
>    752          /* drop the ref from either the old current pool,
>    753           * or the new pool we failed to add
>    754           */
>    755          if (put_pool)
>    756                  zswap_pool_put(put_pool);
>    757
>    758          return ret;
>  > 759  }
>    760
>    761  static int zswap_compressor_param_set(const char *val,
>    762                                        const struct kernel_param *kp)
>    763  {
>    764          return __zswap_param_set(val, kp, zswap_zpool_type, NULL);
>    765  }
>    766
>    767  static int zswap_zpool_param_set(const char *val,
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
