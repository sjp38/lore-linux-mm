Subject: Re: [PATCH 00/32] Swap over NFS - v19
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20081003141731.37bda8f3@doriath.conectiva>
References: <20081002130504.927878499@chello.nl>
	 <20081003141731.37bda8f3@doriath.conectiva>
Content-Type: text/plain
Date: Sat, 04 Oct 2008 12:13:07 +0200
Message-Id: <1223115187.28938.19.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Fri, 2008-10-03 at 14:17 -0300, Luiz Fernando N. Capitulino wrote:
> Em Thu, 02 Oct 2008 15:05:04 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> escreveu:
> 
> | Patches are against: v2.6.27-rc5-mm1
> | 
> | This release features more comments and (hopefully) better Changelogs.
> | Also the netns stuff got sorted and ipv6 will now build and not oops
> | on boot ;-)
> | 
> | The first 4 patches are cleanups and can go in if the respective maintainers
> | agree.
> | 
> | The code is lightly tested but seems to work on my default config.
> | 
> | Let's get this ball rolling...
> 
>  What's the best way to test this? Create a swap in a NFS mount
> point and stress it?

What I do is boot with mem=256M, then swapoff -a;
swapon /net/host/$path/file.swp;

the file.swp I created using dd and mkswap on the remote host.

I then run 2 cyclic loops on anonymous memory sized 96mb, and run 2
cyclic loops on file backed memory on the same NFS mount
(eg /net/host/$path/file[12]), also sized 96mb

That gives a memory footprint of 4*96=384mb and will thus rely on paging
quite heavily.

While this is on-going you can have a little deamon that listens and
accepts connections and reads from them.

On a 3rd machine, start say a 1000 connections to this deamon that
continuously write stuff to it.

Then on you NFS host do something like: /etc/init.d/nfs stop

go for lunch

and when you're back do: /etc/init.d/nfs start

and see if all comes back up again ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
