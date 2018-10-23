Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C01C6B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 15:48:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 87-v6so1553727pfq.8
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 12:48:35 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p9-v6si2158124pfh.232.2018.10.23.12.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 12:48:33 -0700 (PDT)
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
 <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
 <20181023152640.GD20085@bombadil.infradead.org>
 <20181023170532.GW18839@dhcp22.suse.cz>
 <98842edb-d462-96b1-311f-27c6ebfc108a@kernel.org>
 <20181023193044.GA139403@joelaf.mtv.corp.google.com>
From: Shuah Khan <shuah@kernel.org>
Message-ID: <024af44a-77e1-1c61-c9b2-64ffbe4f7c49@kernel.org>
Date: Tue, 23 Oct 2018 13:48:32 -0600
MIME-Version: 1.0
In-Reply-To: <20181023193044.GA139403@joelaf.mtv.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, maco@android.com, Shuah Khan <shuah@kernel.org>

On 10/23/2018 01:30 PM, Joel Fernandes wrote:
> On Tue, Oct 23, 2018 at 11:13:36AM -0600, Shuah Khan wrote:
>> On 10/23/2018 11:05 AM, Michal Hocko wrote:
>>> On Tue 23-10-18 08:26:40, Matthew Wilcox wrote:
>>>> On Tue, Oct 23, 2018 at 09:02:56AM -0600, Shuah Khan wrote:
>>> [...]
>>>>> The way it can be handled is by adding a test module under lib. test_kmod,
>>>>> test_sysctl, test_user_copy etc.
>>>>
>>>> The problem is that said module can only invoke functions which are
>>>> exported using EXPORT_SYMBOL.  And there's a cost to exporting them,
>>>> which I don't think we're willing to pay, purely to get test coverage.
>>>
>>> Yes, I think we do not want to export internal functionality which might
>>> be still interesting for the testing coverage. Maybe we want something
>>> like EXPORT_SYMBOL_KSELFTEST which would allow to link within the
>>> kselftest machinery but it wouldn't allow the same for general modules
>>> and will not give any API promisses.
>>>
>>
>> I like this proposal. I think we will open up lot of test opportunities with
>> this approach.
>>
>> Maybe we can use this stress test as a pilot and see where it takes us.
> 
> I am a bit worried that such an EXPORT_SYMBOL_KSELFTEST mechanism can be abused by
> out-of-tree module writers to call internal functionality.

That is  valid concern to consider before we go forward with the proposal.

We could wrap EXPORT_SYMBOL_KSELFTEST this in an existing debug option. This could
be fine grained for each sub-system for its debug option. We do have a few of these
now

# CONFIG_STATIC_KEYS_SELFTEST is not set
# CONFIG_BT_SELFTEST is not set
# CONFIG_DRM_DEBUG_SELFTEST is not set
# CONFIG_CHASH_SELFTEST is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_RANDOM32_SELFTEST is not set
# CONFIG_GLOB_SELFTEST is not set
# CONFIG_STRING_SELFTEST is not set
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_WW_MUTEX_SELFTEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_X86_DECODER_SELFTEST is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set

thanks,
-- Shuah
