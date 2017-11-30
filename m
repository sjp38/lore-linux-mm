Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDEFC6B0069
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:58:47 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id r70so6803521ioi.2
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 11:58:47 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r185sor2477487itr.53.2017.11.30.11.58.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 11:58:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+om_oZ63OkJwGJNpVgBPxm9Nwc_JwbR3cpfugDPN7X+w@mail.gmail.com>
References: <20171126063117.oytmra3tqoj5546u@wfg-t540p.sh.intel.com>
 <20171127210301.GA55812@localhost.corp.microsoft.com> <20171128124534.3jvuala525wvn64r@wfg-t540p.sh.intel.com>
 <20171129175430.GA58181@big-sky.attlocal.net> <CACT4Y+bji1JMJVJZdv=+bD8JZ1kqrmJ0PWXvHdYzRFcnAKDSGw@mail.gmail.com>
 <CAGXu5jLOojG_Nc50KhdHsXDQQ27G+kOPp6-5kQz7Yh5Vpgucnw@mail.gmail.com>
 <20171130192257.GB1529@localhost> <CAGXu5j+om_oZ63OkJwGJNpVgBPxm9Nwc_JwbR3cpfugDPN7X+w@mail.gmail.com>
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Thu, 30 Nov 2017 19:58:45 +0000
Message-ID: <CAKv+Gu-4JqNiHLo+EAbiEQ+jBNUW0iuyZQs=Do+KajKaibsZuw@mail.gmail.com>
Subject: Re: [pcpu] BUG: KASAN: use-after-scope in pcpu_setup_first_chunk+0x1e3b/0x29e2
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Dennis Zhou <dennisszhou@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Josef Bacik <jbacik@fb.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>

On 30 November 2017 at 19:56, Kees Cook <keescook@chromium.org> wrote:
> On Thu, Nov 30, 2017 at 11:22 AM, Dennis Zhou <dennisszhou@gmail.com> wrote:
>> Hi Dmitry and Kees,
>>
>> On Thu, Nov 30, 2017 at 10:10:41AM -0800, Kees Cook wrote:
>>> > Are we sure that structleak plugin is not at fault? If yes, then we
>>> > need to report this to https://gcc.gnu.org/bugzilla/ with instructions
>>> > on how to build/use the plugin.
>>
>> I believe this is an issue with the structleak plugin and not gcc. The
>> bug does not show up if you compile without
>> GCC_PLUGIN_STRUCTLEAK_BYREF_ALL.
>>
>> It seems to be caused by the initializer not respecting the ASAN_MARK
>> calls. Therefore, if an inlined function gets called from a for loop,
>> the initializer code gets invoked bugging in the second iteration. Below
>> is the tree dump for the structleak plugin from the reproducer in the
>> previous email. In bb 2 of INIT_LIST_HEAD, the __u = {} is before the
>> unpoison call. This is inlined in bb 3 of main.
>
> Ah-ha, okay. Thanks for the close examination. Ard, is this something
> you have a few moment to take a look at?
>

I must admit that I am a bit out of my depth here. Also, I am quite
sure this is a pre-existing issue with the plugin which is triggered
more easily because it affects many more initializers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
