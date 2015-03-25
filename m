Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2F86B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:50:33 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so44109463wgb.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 15:50:32 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id cj14si6732936wjb.209.2015.03.25.15.50.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 15:50:31 -0700 (PDT)
Message-ID: <55133BAF.30301@nod.at>
Date: Wed, 25 Mar 2015 23:50:23 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp>
In-Reply-To: <m2bnjhcevt.wl@sfc.wide.ad.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, mathieu.lacage@gmail.com

Hi!

Am 25.03.2015 um 15:48 schrieb Hajime Tazaki:
> 
> At Tue, 24 Mar 2015 16:27:51 +0100,
> Richard Weinberger wrote:
>>
>> I'd say you should try hard to re-use/integrate your work in arch/um.
>> With um we already have an architecture which targets userspace,
>> having two needs a very good justification.
> 
> in addition to the case of my previous email, libos is not
> limited to run on user-mode: it is just a library which can
> be used with various programs. thus it has a potential (not
> implemented yet) to run on a hypervisor like OSv or MirageOS
> does for application containment, or run on a bare-metal
> machine as rumpkernel does. We already have a clear
> interface for the underlying layer to be able to add such
> backend.
> 
> again, it's not only for user-mode.
> 
> mixing all the stuff in a single architecture may not only
> mislead to users, but also introduce conceptual-disagreements
> during code sharing of essential parts. 
> 
> I don't see any benefits to have a name 'um' with this idea.
> 
> # I'm not saying sharing a part of code is bad idea at all, btw.

After digging into the source I know what you mean and I have the
feeling that "lib" is the wrong name.
It has not much do to with an architecture.
Apart from that, I really like your idea!

You don't implement an architecture, you take some part of Linux
(the networking stack) and create stubs around it to make it work.
That means that we'd also have to duplicate kernel functions into
arch/lib to keep it running.

BTW: It does not build here:
---cut---
  LIB           liblinux-4.0.0-rc5.so
Cloning into 'arch/lib/tools'...
remote: Counting objects: 93, done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 93 (delta 9), reused 0 (delta 0), pack-reused 74
Receiving objects: 100% (93/93), 59.77 KiB | 0 bytes/s, done.
Resolving deltas: 100% (43/43), done.
Checking connectivity... done
  CC       nuse-fiber.o
  CC       nuse-vif.o
  CC       nuse-hostcalls.o
  CC       nuse-config.o
  CC       nuse-vif-rawsock.o
  CC       nuse-vif-tap.o
  CC       nuse-glue.o
  CC       nuse-vif-pipe.o
  CC       nuse.o
make[2]: *** No rule to make target `rump/lib/librumpuser/rumpuser_sp.c', needed by `rump/lib/librumpuser/rumpuser_sp.o'.  Stop.
make[2]: *** Waiting for unfinished jobs....
  CC       sim.o
  GEN      git-sparse
make[2]: *** No rule to make target `rump/lib/librumpclient/rumpclient.c', needed by `rump/lib/librumpclient/rumpclient.o'.  Stop.
make[1]: *** [librumpclient.so] Error 2
make[1]: *** Waiting for unfinished jobs....
nuse.c: In function 'nuse_dev_rx':
nuse.c:279:5: warning: unused variable 'hdr' [-Wunused-variable]
  } *hdr = (struct ethhdr *)buf;
     ^
make[1]: *** [librumpserver.so] Error 2
make: *** [arch/lib/tools] Error 2
---cut---

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
