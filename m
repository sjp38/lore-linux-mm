Message-ID: <4693E77D.2020706@oracle.com>
Date: Tue, 10 Jul 2007 13:09:33 -0700
From: Herbert van den Bergh <Herbert.van.den.Bergh@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] include private data mappings in RLIMIT_DATA limit
References: <4692D616.4010004@oracle.com> <200707101219.29743.dave.mccracken@oracle.com> <Pine.LNX.4.64.0707101857310.20758@blonde.wat.veritas.com> <200707101412.19785.dave.mccracken@oracle.com> <Pine.LNX.4.64.0707102030150.2063@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0707102030150.2063@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Dave McCracken <dave.mccracken@oracle.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hugh Dickins wrote:
> On Tue, 10 Jul 2007, Dave McCracken wrote:
>> On Tuesday 10 July 2007, Hugh Dickins wrote:
>>> Mapped private readonly yes, but vm_stat_account() says
>>> 	if (file) {
>>> 		mm->shared_vm += pages;
>>> 		if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
>>> 			mm->exec_vm += pages;
>> In that code shared_vm includes everything that's mmap()ed, including private 
>> mappings.  But if you look at Herbert's patch he has the following change:
>>
>>         if (file) {
>> -               mm->shared_vm += pages;
>> +               if (flags & VM_SHARED)
>> +                       mm->shared_vm += pages;
>>                 if ((flags & (VM_EXEC|VM_WRITE)) == VM_EXEC)
>>                         mm->exec_vm += pages;
>>
>> This means that shared_vm now is truly only memory that's mapped VM_SHARED and 
>> does not include VM_EXEC memory.  That necessitates the separate subtraction 
>> of exec_vm in the data calculations.
> 
> Ah, I just noticed at the beginning of the patch, and didn't look for
> a balancing change - thanks.  I'd strongly recommend that he not mess
> around with these numbers, unless there's _very_ good reason: they're
> not ideal, nothing ever will be, changing them around just causes pain.
> shared_vm may not be a full description of what it counts, but it'll
> do until you've a better name (readonly mappings share with the file
> even when they're private).

The result of counting only VM_SHARED file mappings in shared_vm is that
it no longer includes MAP_PRIVATE file mappings.  These file mappings are
shared until they are written to, at which point they become private.
The vm doesn't currently track this change from shared to private,
so either way the accounting is off by a bit.  But the intention of the
private mapping is to not share the page with other processes, so I think
the right thing to do is to charge the process with this memory usage as
private memory.  I am continuing to make the assumption that the code
already made that all VM_EXEC mappings are also shared.  But one thing
that has changed is that when a mapping is no longer VM_EXEC, it is also
no longer counted as shared, but as private, and charged to the data size.

This has generally little effect on /proc/pid/stats VmData.

One of the motivations for this change was to make it easier for a
system administrator to manage processes that could allocate large
amounts of private memory, either through malloc() or through mmap(),
possibly due to programming errors.  As Dave also pointed out, if these
processes need to be able to attach to large shared memory segments, such
as a database buffer cache, then attempting to control the memory usage of
these processes with RLIMIT_AS becomes very tricky.  The sysadmin may set
the RLIMIT_AS to the current buffer cache shared memory segment size of
say 8GB plus 200M for process private allocations, but the next day the
DBA decides to increase the shared memory segment to 10GB, and wonders
why his processes won't start.  Now, with RLIMIT_DATA being effective again,
all that is needed is to set RLIMIT_DATA to a reasonable value for the 
application.

I don't anticipate that a lot of people need to be concerned about the 
effect of this resource limit change.  By default RLIMIT_DATA is set to
unlimited.  For those who do want to set it, they will need to understand 
what it does, just like any other resource limit.

Perhaps an update of the man page is in order as well.

Thanks,
Herbert.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
