Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA28256
	for <linux-mm@kvack.org>; Tue, 17 Sep 2002 13:12:24 -0700 (PDT)
Message-ID: <3D878CA6.DE7BADDD@digeo.com>
Date: Tue, 17 Sep 2002 13:12:22 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 35-mm1 triggers watchdog
References: <3D86BE4F.75C9B6CC@digeo.com> <20020917072716.GN3530@holomorphy.com> <3D86E19B.6476A9EA@digeo.com> <200209170738.48565.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi Andrew,
> 
> I have had 35-mm1 reboot twice via the software watchdog.  What is the best
> way to debug this.  I do have a serial term and can rebuild patched with the
> kernel debugger, just need some instructions on how to catch the stall and
> what info to gather.  Is there a good FAQ on kernel debugger?

Normally ksymoops will tell you where it was locked when
the NMI watchdog hit.  Aren't you getting a stack trace?

Kernel debugger?  kgdb.sourceforge.net, with patches from
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.35/2.5.35-mm1/experimental/

You're best off cross-compiling so the source, vmlinux, etc are on the
workstation and you copy kernels to the test box.

umm,

- patch the kernel
- enable kgdb in config
- build it, lilo it, add:

	gdb gdbbaud=115200 gdbttyS=ttyS1

  to the kernel boot line.

- Put my .gdbinit in $HOME.

- reboot test box

- gdb vmlinux
  rmt
  (gdb) c

- Run test, wait for NMI watchdog.

Sometimes it's a bit hard to work out _why_ the target trapped into
the debugger, so I changed kgdb to deliver a SIGEMT in response to
NMI rather than SIGBUS/SIGSEGV.






set editing on
set radix 0x0a

define rmt
set remotebaud 115200
target remote /dev/ttyS0
end

define comm25
p ((struct thread_info *)((int)$esp & ~0x1fff))->task->comm
end

define task25
p ((struct thread_info *)((int)$esp & ~0x1fff))->task
end

define thread25
p ((struct thread_info *)((int)$esp & ~0x1fff))
end

define reboot
	maintenance packet r
end

#process information macros
define psname
	if $arg0 == 0 
		set $athread =  init_tasks[0]
	else 
		set $athread = pidhash[(($arg0 >> 8) ^ $arg0) & 1023]
	end
	if $athread != 0 
		while $athread->pid != $arg0 && $athread != 0
			set $athread = $athread->hash_next
		end
		if $athread != 0 
			printf "%d %s\n", $arg0, (char*)$athread->comm
		end
	end
end
define ps
	set $initthread = init_tasks[0]
	set $athread = init_tasks[0]
	printf "%d %s\n", $athread->pid, (char*)($athread->comm)
	set $athread = $athread->next_task
	while $athread != ($initthread)
		if ($athread->pid) != (0)
			printf "%d %s\n", $athread->pid, (char*)$athread->comm
		end
		set $athread = $athread->next_task
	end
end


define page_states
printf "Dirty: %dK\n", (page_states[0].nr_dirty + page_states[1].nr_dirty + page_states[2].nr_dirty + page_states[3].nr_dirty) * 4
printf "Writeback: %dK\n", (page_states[0].nr_writeback + page_states[1].nr_writeback + page_states[2].nr_writeback + page_states[3].nr_writeback) * 4
printf "Pagecache: %dK\n", (page_states[0].nr_pagecache + page_states[1].nr_pagecache + page_states[2].nr_pagecache + page_states[3].nr_pagecache) * 4
printf "Page Table Pages: %d\n", (page_states[0].nr_page_table_pages + page_states[1].nr_page_table_pages + page_states[2].nr_page_table_pages + page_states[3].nr_page_table_pages) * 4
printf "nr_reverse_maps: %d\n", page_states[0].nr_reverse_maps + page_states[1].nr_reverse_maps + page_states[2].nr_reverse_maps + page_states[3].nr_reverse_maps
end


define offsetof
	set $off = &(((struct $arg0 *)0)->$arg1)
	printf "%d 0x%x\n", $off, $off
end

# list_entry list type member
define list_entry
	set $off = (int)&(((struct $arg1 *)0)->$arg2)
	set $addr = (int)$arg0
	set $res = $addr - $off
	printf "0x%x\n", $res
end
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
