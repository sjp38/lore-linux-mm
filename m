Date: Tue, 12 Sep 2000 12:54:03 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH] workaround for lost dirty bits on x86 SMP
In-Reply-To: <20000912112438.C28418@redhat.com>
Message-ID: <Pine.LNX.4.21.0009121250510.7545-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2000, Stephen C. Tweedie wrote:

> Of course it won't, because you aren't testing the new behaviour!
> Anonymous pages are always dirty, and shared mmaped pages in
> MAP_PRIVATE regions are always clean.  The only place where you need
> to track the dirty bit dynamically is when you use shared writeable
> mmaps --- can you measure a performance change there?

Here's a more realistic test, and yes it does extract a heavy performance
hit -- unpatched read then write to 1 byte of 1GB of pages:

size is 1073741825
addr = 0x4010f000
read fault test: start=29670620301256 stop=29670945360465, elapsed=325059209
write fault test: start=29670945400339 stop=29671024199394, elapsed=78799055

patched:

size is 1073741825
addr = 0x4010f000
read fault test: start=135059091263 stop=135383514415, elapsed=324423152
write fault test: start=135383569394 stop=135664481836, elapsed=280912442

So, let's see what can be done to speed up the clean to dirty fault
path...  (more later)

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
