Date: Fri, 28 Mar 2008 14:11:56 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: [PATCH 0/8] - Support for UV platform
Message-ID: <20080328191156.GA16415@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This series of patches add x86_64 support for the SGI "UV" platform.
Most of the changes are related to support for larger apic IDs and
new chipset hardware that is used for sending IPIs, etc.

UV supports really big systems. So big, in fact, that the APICID register
does not contain enough bits to contain an APICID that is unique across all
cpus.

The UV BIOS supports 3 APICID modes:

        - legacy mode. This mode uses the old APIC mode where
          APICID is in bits [31:24] of the APICID register.

        - x2apic mode. This mode is whitebox-compatible. APICIDs
          are unique across all cpus. Standard x2apic APIC operations
          (Intel-defined) can be used for IPIs. The node identifier
          fits within the Intel-defined portion of the APICID register.

        - x2apic-uv mode. In this mode, the APICIDs on each node have
          unique IDs, but IDs on different node are not unique. For example,
          if each mode has 32 cpus, the APICIDs on each node might be
          0 - 31. Every node has the same set of IDs.
          The UV hub is used to route IPIs/interrupts to the correct node.
          Traditional APIC IPI operations WILL NOT WORK.


In x2apic-uv mode, the ACPI tables all contain a full unique ID:
        nnnnnnnnnnlc0cch
                n = unique node number
                l = socket number on board
                c = core
                h = hyperthread

Only the "c0cch" bits are written to the APICID register. The remaining bits are
supplied by having the get_apic_id() function "OR" the extra bits into the value
read from the APICID register. 

The x2apic-uv mode is recognized by <oem_id> & <oem_table_id> fields of
the MADT table.


Significant changes from V1:
	- fixed issues raised in review of the first patch
		- move uv header files to asm-x86/uv
		- deleted support for using UV header files in BIOS
		- Add WARN if reading apicid w/o disabling preemption (& fixed
		  places that hit the WARN)
		- added _GPL to exports
		- deleted some debug code
	- reworked the macros/functions for reading the APIC_ID. This was necessary
	  because several of the apic-related files that use to be separate for -32
	  and -64 have been combined.
	- added null macros for -32 for is_uv_system() - fixed a couple of compile
	  bugs for 32-bit kernels

Remaining issues that will be addressed later
	- smpboot_32.c & smpboot_64.c were recently combined. I pulled the code
	  from this patch that is needed to start slave cpus when running in 
	  x2apic-uv mode because it collided to too much 32-bit code. I'll
	  add this again in a subsequent patch. The current code fully supports
	  legacy (& x2apic mode once the Intel x2apic patch is available) - that
	  is good enough for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
