Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 905F86B0294
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:14:51 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id d14-v6so17177623qtn.3
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:14:51 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k24-v6si2041567qta.239.2018.06.26.10.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 10:14:50 -0700 (PDT)
Message-ID: <a8343284adff3c743121a339035d5010347a3038.camel@redhat.com>
Subject: Re: [PATCH] add param that allows bootline control of hardened
 usercopy
From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 26 Jun 2018 19:14:47 +0200
In-Reply-To: <CAGXu5jKHz=OaU1ejYEB=t-=Gs6gVoRywFbyQw8ThHk6WYG7Qxg@mail.gmail.com>
References: 
	<CAGXu5jL=aEXHKr5ouVdSKwG-y7xSQFLi=x1nwSjFspYiyKL1Pw@mail.gmail.com>
	 <64bf81fa-0363-4b46-d8da-94285b592caa@redhat.com>
	 <a48538cf40c1645669326c92d9600fc98a13a260.camel@redhat.com>
	 <CAGXu5jKHz=OaU1ejYEB=t-=Gs6gVoRywFbyQw8ThHk6WYG7Qxg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Chris von Recklinghausen <crecklin@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

[hopefully fixed the 'mm' recipient]

On Tue, 2018-06-26 at 09:54 -0700, Kees Cook wrote:
> On Tue, Jun 26, 2018 at 2:48 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > With CONFIG_HARDENED_USERCOPY=y, perf shows ~6% of CPU time spent
> > cumulatively in __check_object_size (~4%) and __virt_addr_valid (~2%).
> 
> Are you able to see which network functions are making the
> __check_object_size() calls?

The call-chain is:

__GI___libc_recvfrom                                                   
entry_SYSCALL_64_after_hwframe                                         
do_syscall_64                                                          
__x64_sys_recvfrom                                                     
__sys_recvfrom                                                         
inet_recvmsg                                                           
udp_recvmsg                                                            
__check_object_size

udp_recvmsg() actually calls copy_to_iter() (inlined) and the latters
calls check_copy_size() (again, inlined).

Cheers,

Paolo
