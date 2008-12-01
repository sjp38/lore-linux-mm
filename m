Date: Mon, 1 Dec 2008 13:02:09 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
In-Reply-To: <1228164679.2971.91.camel@nimitz>
Message-ID: <alpine.LFD.2.00.0812011258390.3256@nehalem.linux-foundation.org>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>  <1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>  <20081128101919.GO28946@ZenIV.linux.org.uk>  <1228153645.2971.36.camel@nimitz>  <493447DD.7010102@cs.columbia.edu>
 <1228164679.2971.91.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>



On Mon, 1 Dec 2008, Dave Hansen wrote:
> 
> Why is this done in two steps?  It first grabs a list of fd numbers
> which needs to be validated, then goes back and turns those into 'struct
> file's which it saves off.  Is there a problem with doing that
> fd->'struct file' conversion under the files->file_lock?

Umm, why do we even worry about this?

Wouldn't it be much better to make sure that all other threads are 
stopped before we snapshot, and if we cannot account for some thread (ie 
there's some elevated count in the fs/files/mm structures that we cannot 
see from the threads we've stopped), just refuse to dump.

There is no sane dump from a multi-threaded app that shares resources 
without that kind of serialization _anyway_, so why even try?

In other words: any races in dumping are fundamental _bugs_ in the dumping 
at a much higher level. There's absolutely no point in trying to make 
something like "dump open fd's" be race-free, because if there are other 
people that are actively accessing the 'files' structure concurrently, you 
had a much more fundamental bug in the first place!

So do things more like the core-dumping does: make sure that all other 
threads are quiescent first!

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
