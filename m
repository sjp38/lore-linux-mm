Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 183FA6B0006
	for <linux-mm@kvack.org>; Sun, 20 May 2018 19:21:44 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u127-v6so13441692qka.9
        for <linux-mm@kvack.org>; Sun, 20 May 2018 16:21:44 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 50-v6sor7285212qvr.94.2018.05.20.16.21.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 May 2018 16:21:43 -0700 (PDT)
Date: Sun, 20 May 2018 19:21:39 -0400
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: Re: [PATCH 00/10] Misc block layer patches for bcachefs
Message-ID: <20180520232139.GE11495@kmo-pixel>
References: <20180509013358.16399-1-kent.overstreet@gmail.com>
 <a26feed52ec6ed371b3d3b0567e31d1ff4fc31cb.camel@wdc.com>
 <20180518090636.GA14738@kmo-pixel>
 <8f62d8f870c6b66e90d3e7f57acee481acff57f5.camel@wdc.com>
 <20180520221733.GA11495@kmo-pixel>
 <bb4fd32d0baa6554615a7ec3b45cc2b89424328e.camel@wdc.com>
 <20180520223116.GB11495@kmo-pixel>
 <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0aa2a8737b2d826fea58dc0bc113ddce50f018a.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "axboe@kernel.dk" <axboe@kernel.dk>

On Sun, May 20, 2018 at 10:35:29PM +0000, Bart Van Assche wrote:
> On Sun, 2018-05-20 at 18:31 -0400, Kent Overstreet wrote:
> > On Sun, May 20, 2018 at 10:19:13PM +0000, Bart Van Assche wrote:
> > > On Sun, 2018-05-20 at 18:17 -0400, Kent Overstreet wrote:
> > > > On Fri, May 18, 2018 at 03:12:27PM +0000, Bart Van Assche wrote:
> > > > > On Fri, 2018-05-18 at 05:06 -0400, Kent Overstreet wrote:
> > > > > > On Thu, May 17, 2018 at 08:54:57PM +0000, Bart Van Assche wrote:
> > > > > > > With Jens' latest for-next branch I hit the kernel warning shown below. Can
> > > > > > > you have a look?
> > > > > > 
> > > > > > Any hints on how to reproduce it?
> > > > > 
> > > > > Sure. This is how I triggered it:
> > > > > * Clone https://github.com/bvanassche/srp-test.
> > > > > * Follow the instructions in README.md.
> > > > > * Run srp-test/run_tests -c -r 10
> > > > 
> > > > Can you bisect it? I don't have infiniband hardware handy...
> > > 
> > > Hello Kent,
> > > 
> > > Have you noticed that the test I described uses the rdma_rxe driver and hence that
> > > no InfiniBand hardware is needed to run that test?
> > 
> > No, I'm not terribly familiar with infiniband stuff....
> > 
> > Do you have some sort of self contained test/qemu recipe? I would really rather
> > not have to figure out how to configure multipath, and infiniband, and I'm not
> > even sure what else is needed based on that readme...
> 
> Hello Kent,
> 
> Please have another look at the srp-test README. The instructions in that document
> are easy to follow. No multipath nor any InfiniBand knowledge is required. The test
> even can be run in a virtual machine in case you would be worried about potential
> impact of the test on the rest of the system.


I really have better things to do than debug someone else's tests...

Restarting multipath-tools (via systemctl): multipath-tools.service.
multipathd> reconfigure
ok
multipathd> make -C discontiguous-io discontiguous-io
make[1]: Entering directory '/host/home/kent/ktest/tests/srp-test/discontiguous-io'
make[1]: 'discontiguous-io' is up to date.
make[1]: Leaving directory '/host/home/kent/ktest/tests/srp-test/discontiguous-io'
Unloaded the ib_srpt kernel module
Unloaded the rdma_rxe kernel module
../run_tests: line 65: cd: /lib/modules/4.16.0+/kernel/block: No such file or directory
Zero-initializing /dev/ram0 ... done
Zero-initializing /dev/ram1 ... done
Unable to load target_core_pscsi
Unable to load target_core_user
Configured SRP target driver
Running test ../tests/01 ...
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/01 failed
Running test ../tests/02-mq ...
Test file I/O on top of multipath concurrently with logout and login (10 min; mq)
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/02-mq failed
Running test ../tests/02-sq ...
Test file I/O on top of multipath concurrently with logout and login (10 min; sq)
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/02-sq failed
Running test ../tests/02-sq-on-mq ...
Test file I/O on top of multipath concurrently with logout and login (10 min; sq-on-mq)
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/02-sq-on-mq failed
Running test ../tests/03-4M ...
Test direct I/O with large transfer sizes and cmd_sg_entries=255
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/03-4M failed
Running test ../tests/03-8M ...
Test direct I/O with large transfer sizes and cmd_sg_entries=255
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/03-8M failed
Running test ../tests/04-4M ...
Test direct I/O with large transfer sizes and cmd_sg_entries=1
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/04-4M failed
Running test ../tests/04-8M ...
Test direct I/O with large transfer sizes and cmd_sg_entries=1
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/04-8M failed
Running test ../tests/05-4M ...
Test buffered I/O with large transfer sizes and cmd_sg_entries=255
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/05-4M failed
Running test ../tests/05-8M ...
Test buffered I/O with large transfer sizes and cmd_sg_entries=255
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/05-8M failed
Running test ../tests/06 ...
Test block I/O on top of multipath concurrently with logout and login (10 min)
Unloaded the ib_srp kernel module
SRP login failed
Test ../tests/06 failed
0 tests succeeded and 11 tests failed
Unloaded the ib_srpt kernel module
Unloaded the rdma_rxe kernel module

========= PASSED srp in 18s
