Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0246A6B0261
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 20:23:01 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id a192so706828pge.1
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 17:23:00 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u10si2655810pgr.576.2017.10.31.17.22.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 17:23:00 -0700 (PDT)
Subject: Re: [PATCH 00/23] KAISER: unmap most of the kernel from userspace
 page tables
References: <20171031223146.6B47C861@viggo.jf.intel.com>
 <CA+55aFzS8GZ7QHzMU-JsievHU5T9LBrFx2fRwkbCB8a_YAxmsw@mail.gmail.com>
 <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d6400e78-4ca5-9837-59bd-fe2e2f8f9f68@intel.com>
Date: Tue, 31 Oct 2017 17:21:56 -0700
MIME-Version: 1.0
In-Reply-To: <9e45a167-3528-8f93-80bf-c333ae6acb71@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>

On 10/31/2017 04:44 PM, Dave Hansen wrote:
>>      That seems insane. Why isn't only tyhe top level shadowed, and
>> then lower levels are shared between the shadowed and the "kernel"
>> page tables?
> There are obviously two PGDs.  The userspace half of the PGD is an exact
> copy so all the lower levels are shared.  You can see this bit in the
> memcpy that we do in clone_pgd_range().

This is wrong.

The userspace copying is done via the code we add to native_set_pgd().
Whenever we set the kernel PGD, we also make sure to make a
corresponding entry in the user/shadow PGD.

The memcpy() that I was talking about does the kernel portion of the PGD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
