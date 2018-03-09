Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3796B0009
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 10:51:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u68so1226034wmd.5
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 07:51:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 37sor684272wrb.33.2018.03.09.07.51.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Mar 2018 07:51:07 -0800 (PST)
Date: Fri, 9 Mar 2018 18:51:04 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 12/25] slub: make ->reserved unsigned int
Message-ID: <20180309155103.GA11093@avx2>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180305200730.15812-12-adobriyan@gmail.com>
 <alpine.DEB.2.20.1803061242530.29393@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803061242530.29393@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 12:43:26PM -0600, Christopher Lameter wrote:
> On Mon, 5 Mar 2018, Alexey Dobriyan wrote:
> 
> > ->reserved is either 0 or sizeof(struct rcu_head), can't be negative.
> 
> Thus it should be size_t? ;-)

:-)

Christoph, using "unsigned int" should be default for kernel really.

As was noted earlier it doesn't matter for constants as x86_64 clears
upper half of a register. But it matters for sizes which aren't known
at compile time.

I've looked at a lot of places where size_t is used.
There is a certain degree of "type correctness" when people try to keep
type as much as possible. It works until first multiplication.

	int n;
	size_t len = sizeof(struct foo0) + n * sizeof(struct foo);

Most likely MOVSX or CDQE will be generated which is not the case
if everything is "unsigned int".

Generally, on x86_64,

	uint32_t > uint64_t > uint16_t
	uint8_t	 >

uint64_t adds REX prefix.
uint16_t additionally adds 66 prefix

uint8_t doesn't add anything but it is suboptimal on embedded archs
which emit "& 0xff" and thus should be used only for trimming memory
usage.

Additionally,

	unsigned int > int

as it is easy for compiler to lose track of value range and generate
size extensions.

There is only one exception, namely, when pointers are mixed with
integers:

	int n;
	void *p = p0 + n;

Quite often, gcc generates bigger code when types are made unsigned.
I don't quite understand how it thinks, but overall code will be smaller
if every signed type is made into unsigned.
