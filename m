Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D77A6B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:54:42 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id o124so1615509yba.19
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 09:54:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 206sor802270ywe.71.2017.11.29.09.54.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 09:54:41 -0800 (PST)
Date: Wed, 29 Nov 2017 11:54:30 -0600
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: Re: [pcpu] BUG: KASAN: use-after-scope in
 pcpu_setup_first_chunk+0x1e3b/0x29e2
Message-ID: <20171129175430.GA58181@big-sky.attlocal.net>
References: <20171126063117.oytmra3tqoj5546u@wfg-t540p.sh.intel.com>
 <20171127210301.GA55812@localhost.corp.microsoft.com>
 <20171128124534.3jvuala525wvn64r@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128124534.3jvuala525wvn64r@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Kees Cook <keescook@chromium.org>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, linux-kernel@vger.kernel.org, lkp@01.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>

Hi everyone,

I spent a bit of time learning more about this problem as Fengguang was
able to determine the root commit f7dd2507893cc3. I reproduced the bug
in userspace to make life a bit easier and below the assignment occurs
before the unpoison. This is fine if we're sequentially proceeding, but
as in the case in percpu, it's calling the function in a for loop
causing the assignment to happen after it has been poisoned in the prior
iteration.

<bb 3> [0.00%]:
  _1 = (long unsigned int) i_4;
  _2 = _1 * 16;
  _3 = p_8 + _2;
  list_14 = _3;
  __u = {};
  ASAN_MARK (UNPOISON, &__u, 8);
  __u.__val = list_14;

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

I don't know how to go about fixing this though. The reproducing code is
below and was compiled with gcc-7 and the structleak_plugin.

I hope this helps.

Thanks,
Dennis

----
#include <stdint.h>
#include <stdlib.h>

#define barrier()

#define WRITE_ONCE(x, val) \
({							\
	union { typeof(x) __val; char __c[1]; } __u =	\
		{ .__val = (typeof(x)) (val) }; \
	__write_once_size(&(x), __u.__c, sizeof(x));	\
	__u.__val;					\
})

typedef         uint8_t		__u8;
typedef         uint16_t	__u16;
typedef         uint32_t	__u32;
typedef         uint64_t	__u64;

static inline __attribute__((always_inline)) void __write_once_size(volatile void *p, void *res, int size)
{
	switch (size) {
	case 1: *(volatile __u8 *)p = *(__u8 *)res; break;
	case 2: *(volatile __u16 *)p = *(__u16 *)res; break;
	case 4: *(volatile __u32 *)p = *(__u32 *)res; break;
	case 8: *(volatile __u64 *)p = *(__u64 *)res; break;
	default:
		barrier();
		__builtin_memcpy((void *)p, (const void *)res, size);
		barrier();
	}
}

struct list_head {
	struct list_head *next, *prev;
};

static inline __attribute__((always_inline)) void INIT_LIST_HEAD(struct list_head *list)
{
	WRITE_ONCE(list->next, list);
	list->prev = list;
}

int main(int argc, char *argv[])
{
	struct list_head *p = malloc(10 * sizeof(struct list_head));
	int i;

	for (i = 0; i < 10; i++) {
		INIT_LIST_HEAD(&p[i]);
	}

	free(p);

	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
