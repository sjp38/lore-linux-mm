From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14517.14046.474143.77633@dukat.scot.redhat.com>
Date: Thu, 24 Feb 2000 13:49:18 +0000 (GMT)
Subject: Re: mmap/munmap semantics
In-Reply-To: <m166velnty.fsf@flinx.hidden>
References: <Pine.LNX.4.10.10002221702370.20791-100000@linux14.zdv.uni-tuebingen.de>
	<14516.11124.729025.321352@dukat.scot.redhat.com>
	<20000224033502.B6548@pcep-jamie.cern.ch>
	<14517.8311.194809.598957@dukat.scot.redhat.com>
	<m166velnty.fsf@flinx.hidden>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, Richard Guenther <richard.guenther@student.uni-tuebingen.de>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, glame-devel@lists.sourceforge.net, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 24 Feb 2000 07:41:45 -0600, ebiederm+eric@ccr.net (Eric W. Biederman)
said:

>> The system will free any whole pages in the specified
>> region.  All modifications will be lost and any swapped
>> out pages will be discarded.  Subsequent access to the
>> region will result in a zero-fill-on-demand fault as
>> though it is being accessed for the first time.
>> Reserved swap space is not affected by this call.

> Which is fine but if it works this way on shared memory it is broken,
> at least unless all mappings set (MADV_DONTNEED) and you can prove there
> was no file-io.  Otherwise you could loose legitimate file writes.

Not necessarily, if this behaviour is defined.  It is no more broken
than the fact that write() can overwrite another process's data, or
truncate() can invalidate another process's mapping.  This is an
explicitly destructive system call and the user must have write access
to the file.

The discarding of modifications is obviously correct if the mapping is
MAP_PRIVATE, but I'd be interested in seeing what other Unixen actually
do on MAP_SHARED maps.  Similarly,

   msync(MS_INVALIDATE)

is expected to discard modifications by some applications (and I've
personally had requests for this funcationality from vendors whose
applications use it on shared memory segments).  Its definition in DU
includes:

  After a successful call to the msync() function with the flags parameter
  set to MS_INVALIDATE, all previous modifications to the file using the
  write() function are visible to the mapped region.  Previous direct
  modifications to the mapped region might be lost.

Again it isn't explicit whether this applies only to MAP_PRIVATE or to
MAP_SHARED too.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
