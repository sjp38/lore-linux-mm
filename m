Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 49A256B0088
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 07:33:55 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id e12so206782fga.8
        for <linux-mm@kvack.org>; Sat, 30 Jan 2010 04:33:52 -0800 (PST)
Message-ID: <4B64272D.8020509@gmail.com>
Date: Sat, 30 Jan 2010 13:33:49 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>	<20100126151202.75bd9347.akpm@linux-foundation.org>	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>	<20100126161952.ee267d1c.akpm@linux-foundation.org>	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>	<20100128001636.2026a6bc@lxorguk.ukuu.org.uk>	<4B622AEE.3080906@gmail.com>	<20100129003547.521a1da9@lxorguk.ukuu.org.uk>	<4B62327F.3010208@gmail.com> <20100129110321.564cb866@lxorguk.ukuu.org.uk>
In-Reply-To: <20100129110321.564cb866@lxorguk.ukuu.org.uk>
Content-Type: multipart/mixed;
 boundary="------------070504030300050103070008"
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070504030300050103070008
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Alan Cox wrote:

>> off by default. Problem is that it breaks java and some other stuff that
>> allocates much more memory than it needs. Very quickly Committed_AS hits
>> CommitLimit and one cannot allocate any more while there is plenty of
>> memory still unused.
> 
> So how about you go and have a complain at the people who are causing
> your problem, rather than the kernel.

That would pass completely unnoticed and ignored as long as overcommit
is enabled by default.

>>> theoretical limit, but you generally need more swap (it's one of the
>>> reasons why things like BSD historically have a '3 * memory' rule).
>> Say I have 8GB of memory and there's always some free, why would I need
>> swap?
> 
> So that all the applications that allocate tons of address space and
> don't use it can swap when you hit that corner case, and as a result you
> don't need to go OOM. You should only get an OOM when you run out of
> memory + swap.

Yes, but unfortunately using swap makes machine crawl with huge disk IO
every time you access some application you haven't been using for a few
hours. So recently more and more people are disabling it completely with
positive experience.

>>> So sounds to me like a problem between the keyboard and screen (coupled
>> Unfortunately it is not. Give me ssh access to your computer (leave
>> overcommit on) and I'll kill your X with anything running on it.
> 
> If you have overcommit on then you can cause stuff to get killed. Thats
> what the option enables.

s/stuff/wrong stuff/

> It's really very simple: overcommit off you must have enough RAM and swap
> to hold all allocations requested. Overcommit on - you don't need this
> but if you do use more than is available on the system something has to
> go.
> 
> It's kind of like banking  overcommit off is proper banking, overcommit
> on is modern western banking.

Hehe, yes and you know the consequences.

If you look at malloc(3) you would see this:

"This means that when malloc() returns non-NULL there is no guarantee
that the memory really is available.  This is a really bad bug."

So, if you don't want to change the OOM algorithm why not fixing this
bug then? And after that change the proc(5) manpage entry for
/proc/sys/vm/overcommit_memory into something like:

0: heuristic overcommit (enable this if you have memory problems with
                          some buggy software)
1: always overcommit, never check
2: always check, never overcommit (this is the default)

Regards,
Vedran


-- 
http://vedranf.net | a8e7a7783ca0d460fee090cc584adc12

--------------070504030300050103070008
Content-Type: text/x-vcard; charset=utf-8;
 name="vedran_furac.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="vedran_furac.vcf"

YmVnaW46dmNhcmQNCmZuO3F1b3RlZC1wcmludGFibGU6VmVkcmFuIEZ1cmE9QzQ9OEQNCm47
cXVvdGVkLXByaW50YWJsZTpGdXJhPUM0PThEO1ZlZHJhbg0KYWRyOjs7Ozs7O0Nyb2F0aWEN
CmVtYWlsO2ludGVybmV0OnZlZHJhbi5mdXJhY0BnbWFpbC5jb20NCngtbW96aWxsYS1odG1s
OkZBTFNFDQp1cmw6aHR0cDovL3ZlZHJhbmYubmV0DQp2ZXJzaW9uOjIuMQ0KZW5kOnZjYXJk
DQoNCg==
--------------070504030300050103070008--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
