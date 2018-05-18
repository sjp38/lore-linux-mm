Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5D89A6B05D6
	for <linux-mm@kvack.org>; Fri, 18 May 2018 09:17:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l47-v6so6644891qtk.21
        for <linux-mm@kvack.org>; Fri, 18 May 2018 06:17:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s51-v6si7574459qtk.219.2018.05.18.06.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 06:17:16 -0700 (PDT)
From: Florian Weimer <fweimer@redhat.com>
Subject: pkeys on POWER: Default AMR, UAMOR values
Message-ID: <36b98132-d87f-9f75-f1a9-feee36ec8ee6@redhat.com>
Date: Fri, 18 May 2018 15:17:14 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, Ram Pai <linuxram@us.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>

I'm working on adding POWER pkeys support to glibc.  The coding work is 
done, but I'm faced with some test suite failures.

Unlike the default x86 configuration, on POWER, existing threads have 
full access to newly allocated keys.

Or, more precisely, in this scenario:

* Thread A launches thread B
* Thread B waits
* Thread A allocations a protection key with pkey_alloc
* Thread A applies the key to a page
* Thread A signals thread B
* Thread B starts to run and accesses the page

Then at the end, the access will be granted.

I hope it's not too late to change this to denied access.

Furthermore, I think the UAMOR value is wrong as well because it 
prevents thread B at the end to set the AMR register.  In particular, if 
I do this

* a?| (as before)
* Thread A signals thread B
* Thread B sets the access rights for the key to PKEY_DISABLE_ACCESS
* Thread B reads the current access rights for the key

then it still gets 0 (all access permitted) because the original UAMOR 
value inherited from thread A prior to the key allocation masks out the 
access right update for the newly allocated key.

Thanks,
Florian
