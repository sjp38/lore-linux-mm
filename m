Message-ID: <47992AA8.6040804@sgi.com>
Date: Thu, 24 Jan 2008 16:17:44 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] percpu: Optimize percpu accesses
References: <20080123044924.508382000@sgi.com> <20080124224613.GA24855@elte.hu>
In-Reply-To: <20080124224613.GA24855@elte.hu>
Content-Type: multipart/mixed;
 boundary="------------030401050506050503060209"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, jeremy@goop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030401050506050503060209
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Ingo Molnar wrote:
> * travis@sgi.com <travis@sgi.com> wrote:
> 
>> This patchset provides the following:
>>
>>   * Generic: Percpu infrastructure to rebase the per cpu area to zero
>>
>>     This provides for the capability of accessing the percpu variables
>>     using a local register instead of having to go through a table
>>     on node 0 to find the cpu-specific offsets.  It also would allow
>>     atomic operations on percpu variables to reduce required locking.
>>
>>   * x86_64: Fold pda into per cpu area
>>
>>     Declare the pda as a per cpu variable. This will move the pda
>>     area to an address accessible by the x86_64 per cpu macros.
>>     Subtraction of __per_cpu_start will make the offset based from
>>     the beginning of the per cpu area.  Since %gs is pointing to the
>>     pda, it will then also point to the per cpu variables and can be
>>     accessed thusly:
>>
>> 	%gs:[&per_cpu_xxxx - __per_cpu_start]
>>
>>   * x86_64: Rebase per cpu variables to zero
>>
>>     Take advantage of the zero-based per cpu area provided above. Then 
>>     we can directly use the x86_32 percpu operations. x86_32 offsets 
>>     %fs by __per_cpu_start. x86_64 has %gs pointing directly to the 
>>     pda and the per cpu area thereby allowing access to the pda with 
>>     the x86_64 pda operations and access to the per cpu variables 
>>     using x86_32 percpu operations.
> 
> tried it on x86.git and 1/3 did not build and 2/3 causes a boot hang 
> with the attached .config.
> 
> 	Ingo
> 

The build error was fixed with the note I sent to you yesterday with a
"fixup" patch for changes in -mm but not in x86.git (attached).

I'll try out your config next.

Thanks,
Mike



--------------030401050506050503060209
Content-Type: text/plain;
 name="zero-based-x86.git-fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="zero-based-x86.git-fix"

Subject: x86: fixes conflict between -mm and x86.git

Ingo - you can apply this to x86.git after the other zero-based
changes to fix a build problem.

Thanks,
Mike

Signed-off-by: Mike Travis <travis@sgi.com>
---
 kernel/module.c |    3 ---
 1 file changed, 3 deletions(-)

--- a/kernel/module.c
+++ b/kernel/module.c
@@ -341,9 +341,6 @@ static inline unsigned int block_size(in
 	return val;
 }
 
-/* Created by linker magic */
-extern char __per_cpu_start[], __per_cpu_end[];
-
 static void *percpu_modalloc(unsigned long size, unsigned long align,
 			     const char *name)
 {

--------------030401050506050503060209--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
