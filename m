Received: from m2hub.mail.wipro.com (m2hub.wipro.com [164.164.27.50])
	by wiprom2mx1.wipro.com (8.9.3+Sun/8.9.3) with ESMTP id RAA07617
	for <linux-mm@kvack.org>; Mon, 9 Apr 2001 17:14:33 GMT
Received: from m2vwall2.wipro.com ([164.164.27.52]) by
          m2hub.mail.wipro.com (Netscape Messaging Server 4.15) with SMTP
          id GBIW1300.GHS for <linux-mm@kvack.org>; Mon, 9 Apr 2001 17:01:51 +0530
Received: from sidcgw.wipsys.soft.net ([164.164.27.8]) by
          benz.mail.wipro.com (Netscape Messaging Server 4.15) with ESMTP
          id GBIW9400.P5Q for <linux-mm@kvack.org>; Mon, 9 Apr 2001 17:06:40 +0530
Received: from wipro.wipsys.sequent.com (wipro.wipsys.sequent.com [192.84.36.6])
	by sidcgw.wipsys.soft.net (8.8.5/8.8.5) with ESMTP id QAA10738
	for <linux-mm@kvack.org>; Mon, 9 Apr 2001 16:54:52 +0530
Received: from localhost (rashmia@localhost)
	by wipro.wipsys.sequent.com (8.8.5/8.8.5) with SMTP id RAA25891
	for <linux-mm@kvack.org>; Mon, 9 Apr 2001 17:08:26 +0530 (IST)
Date: Mon, 9 Apr 2001 17:08:26 +0530 (IST)
From: Rashmi Agrawal <rashmi.agrawal@wipro.com>
Subject: Need clarification regarding sharedram in sysinfo()
Message-ID: <Pine.PTX.3.96.1010409165638.3805T-100000@wipro.wipsys.sequent.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

For system call sysinfo() in linux 2.2.14, it calculates the total
sharedram using si_meminfo(). Here from high_memory i it tries to do the
following
	
	while (i-- > 0)  {
                if (PageReserved(mem_map+i))
                        continue;
                val->totalram++;
                if (!atomic_read(&mem_map[i].count))
                        continue;
                val->sharedram += atomic_read(&mem_map[i].count) - 1;
        }

Here except for the reserved page all the pages increase totalram. And
after that if the value of "atomic_read(&mem_map[i].count)" is zero which
means, I suppose nobody is referencing it, it continues. Otherwise it adds
to the sharedram, for that it does
		val->sharedram += atomic_read(&mem_map[i].count) - 1

What atomic_read(&mem_map[i].count) does is simply reading the 
count which is atomic_t datatype. This value gets increased when the
reference to that page gets increased. So if there are 3 processes which
are accessing the same page the count will be 3. And my understanding is 1
shared page and 3 references here. But here, the way  its calculating the
sharedram is, sharedram += no_of_references -1. Which is slightly
confusing.

So can anybody clarify, what exactly the sharedram supposed to be in this?

Please reply to my id rashmi.agrawal@wipro.com
Regards
Rashmi Agrawal
Wipro Global R & D
Ph : 080-5732296(5236)
=====================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
