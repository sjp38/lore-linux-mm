Date: Thu, 17 Jul 2008 17:20:23 -0400
From: Daniel Jacobowitz <drow@false.org>
Subject: Re: [Bugme-new] [Bug 11110] New: Core dumps do not include
	writable unmodified MAP_PRIVATE maps
Message-ID: <20080717212023.GA20584@caradoc.them.org>
References: <bug-11110-10286@http.bugzilla.kernel.org/> <20080717132317.96e73124.akpm@linux-foundation.org> <20080717203930.GA24299@hmsendeavour.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080717203930.GA24299@hmsendeavour.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Horman <nhorman@tuxdriver.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, Roland McGrath <roland@redhat.com>, Oleg Nesterov <oleg@tv-sign.ru>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 17, 2008 at 04:39:30PM -0400, Neil Horman wrote:
> I'm not 100% sure, and I can see why the kernel might skip over untouched pages,
> but that seems like a bug to me.  The memory is mapped, it should be readable by
> gdb after a core dump, and since its a mapped file, it can't be assumed to be
> zero, like heap memory that hasn't been faulted in yet.

I'm guessing this is an attempt not to dump shared library text
segments.  We can't do it solely based on permissions; if I remember
right there's a readonly page in the application or ld.so associated
with the shared library list that is mprotected to read-only after
initialization (-z relro).

In April 2006 Dave M suggested only skipping if VM_EXEC.  This will
dump some text segment bits (e.g. anything that had a software
breakpoint inserted), but not most; writable data is usually written
to (at least mostly).

-- 
Daniel Jacobowitz
CodeSourcery

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
