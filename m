Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA17669
	for <linux-mm@kvack.org>; Thu, 23 Apr 1998 20:42:08 -0400
Subject: Re: filemap_nopage is broken!!
References: <m1vhs1oa10.fsf@flinx.npwt.net>
	<199804232201.XAA02883@dax.dcs.ed.ac.uk>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 23 Apr 1998 19:51:16 -0500
In-Reply-To: "Stephen C. Tweedie"'s message of Thu, 23 Apr 1998 23:01:32 +0100
Message-ID: <m1wwcgm48r.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ST" == Stephen C Tweedie <sct@dcs.ed.ac.uk> writes:

ST> I don't think this is necessarily a problem.  The kernel simply does not
ST> guarantee full correspondance semantics between filesystem updates and
ST> the page cache for non-aligned pages, but then again, it is not required
ST> to --- it is not even required to support such mmaps, so I can live with
ST> an undefined behaviour in this case!

Ah, but suppose we have a mythological a.out programmer.
This programmer could run a program, doesn't like the result, compiles
a new version which overwrites the old, and attempts to execute the
new program.  And executes the old!

There may be a lock in there that I haven't spotted, and likely there
will be a truncation when the file is overwritten which would flush
the page cache but it is possible there isn't.

As the kernel internally uses these mappings for a.out executables
this is an undefined case which propogates.  It's undefined which
a.out program executes :(  That part is much harder to live with.

I guess what is I find most objectionable is 
a) There is no big fat warning anywhere.
b) The current implementation will pass simple tests so it will look
   like it works, and then fail at strange weird unpredictable times.

I doubt it will be anything like a show stopper for 2.2 but if this
code get's touched it should be fixed to do something consistent.  

Eric
