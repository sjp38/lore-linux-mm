Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC63C6B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 11:03:29 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id z136-v6so1697859itc.5
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 08:03:29 -0700 (PDT)
Received: from mailout.easymail.ca (mailout.easymail.ca. [64.68.200.34])
        by mx.google.com with ESMTPS id 11-v6si1423864itp.24.2018.10.23.08.03.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Oct 2018 08:03:23 -0700 (PDT)
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
References: <20181019173538.590-1-urezki@gmail.com>
 <20181022125142.GD18839@dhcp22.suse.cz>
 <20181022165253.uphv3xzqivh44o3d@pc636>
 <20181023072306.GN18839@dhcp22.suse.cz>
From: Shuah Khan <shuah@kernel.org>
Message-ID: <dd0c3528-9c01-12bc-3400-ca88060cb7cf@kernel.org>
Date: Tue, 23 Oct 2018 09:02:56 -0600
MIME-Version: 1.0
In-Reply-To: <20181023072306.GN18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Uladzislau Rezki <urezki@gmail.com>, Kees Cook <keescook@chromium.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Shuah Khan <shuah@kernel.org>

Hi Michal,

On 10/23/2018 01:23 AM, Michal Hocko wrote:
> Hi Shuah,
> 
> On Mon 22-10-18 18:52:53, Uladzislau Rezki wrote:
>> On Mon, Oct 22, 2018 at 02:51:42PM +0200, Michal Hocko wrote:
>>> Hi,
>>> I haven't read through the implementation yet but I have say that I
>>> really love this cover letter. It is clear on intetion, it covers design
>>> from high level enough to start discussion and provides a very nice
>>> testing coverage. Nice work!
>>>
>>> I also think that we need a better performing vmalloc implementation
>>> long term because of the increasing number of kvmalloc users.
>>>
>>> I just have two mostly workflow specific comments.
>>>
>>>> A test-suite patch you can find here, it is based on 4.18 kernel.
>>>> ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
>>>
>>> Can you fit this stress test into the standard self test machinery?
>>>
>> If you mean "tools/testing/selftests", then i can fit that as a kernel module.
>> But not all the tests i can trigger from kernel module, because 3 of 8 tests
>> use __vmalloc_node_range() function that is not marked as EXPORT_SYMBOL.
> 
> Is there any way to conditionally export these internal symbols just for
> kselftests? Or is there any other standard way how to test internal
> functionality that is not exported to modules?
> 

The way it can be handled is by adding a test module under lib. test_kmod,
test_sysctl, test_user_copy etc.

There is a corresponding test script e.g selftests/kmod/kmod.sh that loads
the module and runs tests.

Take a look at lib/test_overflow.c - It is running some vmalloc_node tests
test_overflow.c:DEFINE_TEST_ALLOC(vmalloc_node,  vfree,	     0, 0, 1);
test_overflow.c:DEFINE_TEST_ALLOC(kvmalloc_node, kvfree,     0, 1, 1);
test_overflow.c:	err |= test_kvmalloc_node(NULL);
test_overflow.c:	err |= test_vmalloc_node(NULL);

This module could be extended to tun these stress tests perhaps? I don't see a
selftests test script for test_overflow, one could be added.

Adding Kees Cook to the thread for input on test_overflow.

thanks,
-- Shuah
