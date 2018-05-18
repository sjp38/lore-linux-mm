Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A63CD6B068B
	for <linux-mm@kvack.org>; Fri, 18 May 2018 17:09:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id t24-v6so7871391qtn.7
        for <linux-mm@kvack.org>; Fri, 18 May 2018 14:09:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 45-v6si612158qvx.28.2018.05.18.14.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 14:09:22 -0700 (PDT)
Subject: Re: pkeys on POWER: Default AMR, UAMOR values
References: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com>
 <20180518174448.GE5479@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <59616677-49c3-c803-963d-c032168de529@redhat.com>
Date: Fri, 18 May 2018 23:09:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180518174448.GE5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

On 05/18/2018 07:44 PM, Ram Pai wrote:
> Florian, is the behavior on x86 any different? A key allocated in the
> context off one thread is not meaningful in the context of any other
> thread.
> 
> Since thread B was created prior to the creation of the key, and the key
> was created in the context of thread A, thread B neither inherits the
> key nor its permissions. Atleast that is how the semantics are supposed
> to work as per the man page.
> 
> man 7 pkey
> 
> " Applications  using  threads  and  protection  keys  should
> be especially careful.  Threads inherit the protection key rights of the
> parent at the time of the clone(2), system call.  Applications should
> either ensure that their own permissions are appropriate for child
> threads at the time when clone(2) is  called,  or ensure that each child
> thread can perform its own initialization of protection key rights."

I reported two separate issues (actually three, but the execve bug is in 
a separate issue).  The default, and the write restrictions.

The default is just a difference to x86 (however, x86 can be booted with 
init_pkru=0 and behaves the same way, but we're probably going to remove 
that).

The POWER implementation has the additional wrinkle that threads 
launched early, before key allocation, can never change access rights 
because they inherited not just the access rights, but also the access 
rights access mask.  This is different from x86, where all threads can 
freely update access rights, and contradicts the behavior in the manpage 
which says that a??each child thread can perform its own initialization of 
protection key rightsa??.  It can't do that if it is launched before key 
allocation, which is not the right behavior IMO.

Thanks,
Florian
