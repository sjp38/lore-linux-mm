Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Qian Cai <cai@gmx.us>
Subject: Re: kmemleak: Early log buffer exceeded (525980) during boot
References: <1541712198.12945.12.camel@gmx.us>
 <D7C9EA14-C812-406F-9570-CFF36F4C3983@gmx.us>
 <20181110165938.lbt6dfamk2ljafcv@localhost>
Message-ID: <a2a9180f-32cf-a0fa-3829-f36133e3b924@gmx.us>
Date: Tue, 27 Nov 2018 23:21:51 -0500
MIME-Version: 1.0
In-Reply-To: <20181110165938.lbt6dfamk2ljafcv@localhost>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kasan-dev@googlegroups.com, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>



On 11/10/18 11:59 AM, Catalin Marinas wrote:
> On Sat, Nov 10, 2018 at 10:08:10AM -0500, Qian Cai wrote:
>> On Nov 8, 2018, at 4:23 PM, Qian Cai <cai@gmx.us> wrote:
>>> The maximum value for DEBUG_KMEMLEAK_EARLY_LOG_SIZE is only 40000, so it
>>> disables kmemleak every time on this aarch64 server running the latest mainline
>>> (b00d209).
>>>
>>> # echo scan > /sys/kernel/debug/kmemleak 
>>> -bash: echo: write error: Device or resource busy
>>>
>>> Any idea on how to enable kmemleak there?
>>
>> I have managed to hard-code DEBUG_KMEMLEAK_EARLY_LOG_SIZE to 600000,
> 
> That's quite a high number, I wouldn't have thought it is needed.
> Basically the early log buffer is only used until the slub allocator
> gets initialised and kmemleak_init() is called from start_kernel(). I
> don't know what allocates that much memory so early.
> 

It turned out that kmemleak does not play well with KASAN on those aarch64 (HPE
Apollo 70 and Huawei TaiShan 2280) servers.

After calling start_kernel()->setup_arch()->kasan_init(), kmemleak early log
buffer went from something like from 280 to 260000. The multitude of
kmemleak_alloc() calls is,

for_each_memblock(memory, reg) x \
while (pgdp++, addr = next, addr != end) x \
while (ptep++, addr = next, addr != end && \ pte_none(READ_ONCE(*ptep)))

Is this expected?
