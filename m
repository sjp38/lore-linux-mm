Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 1C49D6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 12:14:44 -0500 (EST)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pB8HEh5R008087
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 8 Dec 2011 12:14:43 -0500
Received: from zod.bos.redhat.com ([10.3.113.5])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pB8HEf0C010229
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-mm@kvack.org>; Thu, 8 Dec 2011 12:14:43 -0500
Date: Thu, 8 Dec 2011 12:14:41 -0500
From: Josh Boyer <jwboyer@redhat.com>
Subject: 3.1 HugeTLB setup regression?
Message-ID: <20111208171440.GA26092@zod.bos.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi All,

We've had a report[1] of an existing hugetlb setup that worked in Fedora
14 (2.6.35.x) and Fedora 15 (2.6.38-3.0?) that no longer works when
using the 3.1.x kernel.  The details in the bug are somewhat sparse on
exactly which kernel version(s) worked and when it stopped working, but
I thought I'd include some of the relevant comments to see if anyone can
think of why this would stop working:

1. Allocate large pages through sysctl.conf, with the following:
# Enable large page memory
kernel.shmmax=25769803776
vm.nr_hugepages=10752
vm.hugetlb_shm_group=1001

There is 24 GB of memory on the server, and I'm allocating 21GB (I have
done
this on Fedora 14 and 15 with no issues.

2. Set /etc/security/limits.conf to allow for memlock to be unlimited
for the
user.
3. Create the hugetlb group, and put the users in that group.
4. Turn off transparent huge pages through a boot parameter
transparent_hugepage=never
5. Run the following java command:

java -XX:+UseLargePages -Xms8g -Xmx8g -version

Actual results:

java -XX:+UseLargePages -Xms8g -Xmx8g -version
OpenJDK 64-Bit Server VM warning: Failed to reserve shared memory (errno
= 28).
java version "1.6.0_22"
OpenJDK Runtime Environment (IcedTea6 1.10.4)
(fedora-60.1.10.4.fc16-x86_64)

Apparently dropping it to use 7G works though:

java -XX:+UseLargePages -Xms7g -Xmx7g -version
java version "1.6.0_22"
OpenJDK Runtime Environment (IcedTea6 1.10.4)
(fedora-60.1.10.4.fc16-x86_64)
OpenJDK 64-Bit Server VM (build 20.0-b11, mixed mode)

I'd appreciate any thoughts or further questions to ask for follow up.

josh

[1] https://bugzilla.redhat.com/show_bug.cgi?id=761262

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
