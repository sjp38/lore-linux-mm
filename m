Message-ID: <47EA7A5A.5030207@sgi.com>
Date: Wed, 26 Mar 2008 09:31:22 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86: Modify Kconfig to allow up to 4096 cpus
References: <20080326014137.934171000@polaris-admin.engr.sgi.com> <20080326014138.292294000@polaris-admin.engr.sgi.com> <20080326160924.GC1789@cs181133002.pp.htv.fi>
In-Reply-To: <20080326160924.GC1789@cs181133002.pp.htv.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adrian Bunk <bunk@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Adrian Bunk wrote:
> On Tue, Mar 25, 2008 at 06:41:39PM -0700, Mike Travis wrote:
>> Increase the limit of NR_CPUS to 4096 and introduce a boolean
>> called "MAXSMP" which when set (e.g. "allyesconfig"), will set
>> NR_CPUS = 4096 and NODES_SHIFT = 9 (512).
> 
> 
> I'm not really getting the point of MAXSMP - people should simply pick 
> their values, and when they want the maximum "(2-4096)" and "(1-15)" 
> already provide this information (except that your patch hides the 
> latter information from the user).
> 
> And with your patch, even with MAXSMP=y people could still set 
> NR_CPUS=7 and NODES_SHIFT=15 or whatever else they want...
> 
> More interesting would be why you want it to set NODES_SHIFT to 
> something less than the maximum value of 15. I'm getting the fact that
> 2^15 > 4096 and that 15 might be nonsensical high, but this sounds more 
> like requiring a patch to limit the range to 9?

I guess the main effect is that "MAXSMP" represents what's really
usable for an architecture based on other factors.  The limit of
NODES_SHIFT = 15 is that it's represented in some places as a signed
16-bit value, so 15 is the hard limit without coding changes, not
an architecture limit.

Thanks,
Mike

> 
> 
>> ...
>> --- linux.trees.git.orig/arch/x86/Kconfig
>> +++ linux.trees.git/arch/x86/Kconfig
>> @@ -522,16 +522,24 @@ config SWIOTLB
>>  	  access 32-bits of memory can be used on systems with more than
>>  	  3 GB of memory. If unsure, say Y.
>>  
>> +config MAXSMP
>> +	bool "Configure Maximum number of SMP Processors"
>> +	depends on X86_64 && SMP
>> +	default n
>> +	help
>> +	  Configure maximum number of CPUS for this architecture.
>> +	  If unsure, say N.
>>  
>>  config NR_CPUS
>> -	int "Maximum number of CPUs (2-255)"
>> -	range 2 255
>> +	int "Maximum number of CPUs (2-4096)"
>> +	range 2 4096
>>  	depends on SMP
>> +	default "4096" if MAXSMP
>>  	default "32" if X86_NUMAQ || X86_SUMMIT || X86_BIGSMP || X86_ES7000
>>  	default "8"
>>  	help
>>  	  This allows you to specify the maximum number of CPUs which this
>> -	  kernel will support.  The maximum supported value is 255 and the
>> +	  kernel will support.  The maximum supported value is 4096 and the
>>  	  minimum value which makes sense is 2.
>>  
>>  	  This is purely to save memory - each supported CPU adds
>> @@ -918,12 +926,16 @@ config NUMA_EMU
>>  	  number of nodes. This is only useful for debugging.
>>  
>>  config NODES_SHIFT
>> -	int "Max num nodes shift(1-15)"
>> +	int "Maximum NUMA Nodes (as a power of 2)"
>>  	range 1 15  if X86_64
>> +	default "9" if MAXSMP
>>  	default "6" if X86_64
>>  	default "4" if X86_NUMAQ
>>  	default "3"
>>  	depends on NEED_MULTIPLE_NODES
>> +	help
>> +	  Specify the maximum number of NUMA Nodes available on the target
>> +	  system.  Increases memory reserved to accomodate various tables.
>>  
>>  config HAVE_ARCH_BOOTMEM_NODE
>>  	def_bool y
>>
> 
> cu
> Adrian
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
