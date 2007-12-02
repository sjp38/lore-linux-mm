Message-ID: <4752D739.5060701@rtr.ca>
Date: Sun, 02 Dec 2007 11:03:05 -0500
From: Mark Lord <lkml@rtr.ca>
MIME-Version: 1.0
Subject: Re: [BUG 2.6.24-rc3-git6] SLUB's ksize() fails for size > 2048.
References: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp> <4752D59B.1020907@rtr.ca>
In-Reply-To: <4752D59B.1020907@rtr.ca>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mark Lord wrote:
> Tetsuo Handa wrote:
>> Hello.
>>
>> I can't pass memory allocated by kmalloc() to ksize()
>> if it is allocated by SLUB allocator and
>> size is larger than (I guess) PAGE_SIZE / 2.
>>
>> Regards.
>>
>> ---------- Kernel config (grep CONFIG_SLUB .config) ----------
>> CONFIG_SLUB_DEBUG=y
>> CONFIG_SLUB=y
>> # CONFIG_SLUB_DEBUG_ON is not set
>>
>> ---------- Testing program (ksize_test.c) ----------
>> #include <linux/module.h>
>> #include <linux/slab.h>
>>
>> static int __init init_ksize_test(void)
>> {
>>         void *p = kmalloc(2049, GFP_KERNEL);
>>         printk("ksize(%p) = %d\n", p, ksize(p));
>>         kfree(p);
>>         return -ENOMEM;
>> }
>>
>> module_init(init_ksize_test)
>>
>> MODULE_LICENSE("GPL");
>>
>> ------------[ cut here ]------------
>> kernel BUG at mm/slub.c:2562!
>> invalid opcode: 0000 [#1] SMP
>> Modules linked in: ksize_test
>>
>> Pid: 8473, comm: modprobe Not tainted (2.6.24-rc3-git6 #4)
>> EIP: 0060:[<c01714a2>] EFLAGS: 00010246 CPU: 1
>> EIP is at ksize+0x1b/0x4a
>> EAX: 00000000 EBX: dd776000 ECX: c16721d0 EDX: 00000000
>> ESI: e081b280 EDI: df3a396c EBP: dd595ea0 ESP: dd595ea0
>>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
>> Process modprobe (pid: 8473, ti=dd595000 task=d347cd60 task.ti=dd595000)
>> Stack: dd595eb8 e081e01a dd595eb8 c014010c ffffffff e08193e0 dd595fb0 
>> c0150b18
>>        00000000 00000000 00001866 00000000 dd4dac00 d347cd60 c14366ac 
>> 00000230
>>        0000135c 0000000e dd4dac00 e081b280 00000000 00000000 00000000 
>> 00000000
>> Call Trace:
>>  [<c0106008>] show_trace_log_lvl+0x1a/0x2f
>>  [<c01060b8>] show_stack_log_lvl+0x9b/0xa3
>>  [<c0106167>] show_registers+0xa7/0x178
>>  [<c010634c>] die+0x114/0x1f5
>>  [<c0417018>] do_trap+0x8a/0xa3
>>  [<c01066ec>] do_invalid_op+0x88/0x92
>>  [<c0416dea>] error_code+0x72/0x78
>>  [<e081e01a>] init_ksize_test+0x1a/0x40 [ksize_test]
>>  [<c0150b18>] sys_init_module+0x13d3/0x14ff
>>  [<c0104f7e>] sysenter_past_esp+0x5f/0xa5
>>  =======================
>> Code: 8b 02 5d 84 c0 b8 00 00 00 00 0f 49 d0 89 d0 c3 55 85 c0 89 e5 
>> 75 04 0f 0b eb fe 31 d2 83 f8 10 74 34 e8 b4 ff ff ff 85 c0 75 04 <0f> 
>> 0b eb fe 8b 40 0c 85 c0 75 04 0f 0b eb fe 8b 10 f6 c6 0c 74
>> EIP: [<c01714a2>] ksize+0x1b/0x4a SS:ESP 0068:dd595ea0
> ..
> 
> Is "p" NULL ?   Where'd your printk() output go to?
..

Mmm.. just tried it here, same result, and "p" is definitely not NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
