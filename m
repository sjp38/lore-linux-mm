Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20041004.050320.78713249.taka@valinux.co.jp>
References: <20041003140723.GD4635@logos.cnet>
	 <20041004.033559.71092746.taka@valinux.co.jp>
	 <1096831287.9667.61.camel@lade.trondhjem.org>
	 <20041004.050320.78713249.taka@valinux.co.jp>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1096836249.9667.100.camel@lade.trondhjem.org>
Mime-Version: 1.0
Date: Sun, 03 Oct 2004 22:44:09 +0200
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, iwamoto@valinux.co.jp, haveblue@us.ibm.com, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, piggin@cyberone.com.au, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pa su , 03/10/2004 klokka 22:03, skreiv Hirokazu Takahashi:

> However, while network is down network/cluster filesystems might not
> release pages forever unlike in the case of block devices, which may
> timeout or returns a error in case of failure.

Where is the difference? As far as the VM is concerned, it is a latency
problem. The fact of whether or not it is a permanent hang, a hang with
a long timeout, or just a slow device is irrelevant because the VM
doesn't actually know about these devices.

> Each filesystem can control what the migration code does.
> If it doesn't have anything to help memory migration, it's possible
> to wait for the network coming up before starting memory migration,
> or give up it if the network happen to be down. That's no problem.

Wrong. It *is* a problem: Filesystems aren't required to know anything
about the particulars of the underlying block/network/... device timeout
semantics either.

Think, for instance about EXT2. Where in the current code do you see
that it is required to detect that it is running on top of something
like the NBD device? Where does it figure out what the latencies of this
device is?

AFAICS, most filesystems in linux/fs/* have no knowledge whatsoever
about the underlying block/network/... devices and their timeout values.
Basing your decision about whether or not you need to manage high
latency situations just by inspecting the filesystem type is therefore
not going to give very reliable results.

Cheers,
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
