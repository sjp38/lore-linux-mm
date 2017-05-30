Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7106B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 13:17:03 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id q81so56400839itc.9
        for <linux-mm@kvack.org>; Tue, 30 May 2017 10:17:03 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id b189si12333837iob.220.2017.05.30.10.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 10:17:02 -0700 (PDT)
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
 <20170515193817.GC7551@dhcp22.suse.cz>
 <9b3d68aa-d2b6-2b02-4e75-f8372cbeb041@oracle.com>
 <20170516083601.GB2481@dhcp22.suse.cz>
 <07a6772b-711d-4fdc-f688-db76f1ec4c45@oracle.com>
 <20170529115358.GJ19725@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <ae992f21-3edf-1ae7-41db-641052e411c7@oracle.com>
Date: Tue, 30 May 2017 13:16:50 -0400
MIME-Version: 1.0
In-Reply-To: <20170529115358.GJ19725@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

> Could you be more specific? E.g. how are other stores done in
> __init_single_page safe then? I am sorry to be dense here but how does
> the full 64B store differ from other stores done in the same function.

Hi Michal,

It is safe to do regular 8-byte and smaller stores (stx, st, sth, stb) 
without membar, but they are slower compared to STBI which require a 
membar before memory can be accessed. So when on SPARC we zero a larger 
span of memory it is faster to use STBI, and do one membar at the end. 
This is why for single thread it is faster to zero multiple pages of 
memory and than initialize only fields that are needed in "struct page". 
I believe the same is true for ppc64, as they clear the whole cacheline 
128-bytes at a time with larger memsets.

Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
