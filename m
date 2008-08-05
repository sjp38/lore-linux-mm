Received: from sj-core-5.cisco.com (sj-core-5.cisco.com [171.71.177.238])
	by sj-dkim-2.cisco.com (8.12.11/8.12.11) with ESMTP id m75M4cuH019685
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 15:04:38 -0700
Received: from sausatlsmtp2.sciatl.com ([192.133.217.159])
	by sj-core-5.cisco.com (8.13.8/8.13.8) with ESMTP id m75M4cC1028252
	for <linux-mm@kvack.org>; Tue, 5 Aug 2008 22:04:38 GMT
Message-ID: <4898CE71.60709@sciatl.com>
Date: Tue, 05 Aug 2008 15:04:33 -0700
From: C Michael Sundius <Michael.sundius@sciatl.com>
MIME-Version: 1.0
Subject: Re: Turning on Sparsemem
References: <488F5D5F.9010006@sciatl.com> <1217368281.13228.72.camel@nimitz>	 <20080730093552.GD1369@brain> <4890957F.6080705@sciatl.com>	 <4898C88E.9070006@sciatl.com> <1217973384.10907.70.camel@nimitz>
In-Reply-To: <1217973384.10907.70.camel@nimitz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, msundius@sundius.com
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Tue, 2008-08-05 at 14:39 -0700, C Michael Sundius wrote:
>   
>> Hi Andy and Dave,
>>
>> I turned on sparsemem as you described before. I am crashing in
>> the mem_init() function when I try a call to pfn_to_page().
>>
>> I've noticed that that macro uses the sparsemem macro 
>> __pfn_to_section(pfn) and
>> that intern calls __nr_to_section(nr). That finally looks at the 
>> mem_section[] variable.
>> well.. this returns NULL since it seems as though my mem_section[] array 
>> looks
>> to be not initialized correctly.
>>
>> QUESTION: where does this array get initialized. I've looked through the 
>> code and
>> can't seem to see how that is initialized.
>>     
>
> My first guess is that you're missing a call to sparse_init() in your
> architecture-specific code.  On x86_32, we do that in paging_init(),
> just before zone_sizes_init() (arch/x86/mm/init_32.c).
>
> Before you call this, you'll also have to call memory_present(...) on
> the memory that you do have.  But, you should probably already have done
> that.
>
>   
yes I call sparse_init()..... My code might be not calling 
memory_present for some of the memory
I'm looking at that right now.
>> recall I'm using mips32 processor, but I've looked in all the processors.
>> it seems as though sparse_init() and memory present() both use 
>> __nr_to_section()
>> and thus would require mem_section[] to be set up already.
>>     
>
> __nr_to_section() is special.  It takes a section number and just gives
> you back the 'struct mem_section'.  It doesn't actually look into that
> mem_section and make sure it is valid, it just locates the data
> structure.
>
> -- Dave
>
>   
still that code is strange to me:

-------------code
static inline struct mem_section *__nr_to_section(unsigned long nr)
{
        if (!mem_section[SECTION_NR_TO_ROOT(nr)])
                return NULL;
        return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
}

--------------

on the first line of the function above, what does it mean "if not 
<struct>"?  seems that returns true if
the contents of that struct is "0"... but either way, doesn't that have 
to be initialized to something before
it is called from memory_present()?

mike



     - - - - -                              Cisco                            - - - - -         
This e-mail and any attachments may contain information which is confidential, 
proprietary, privileged or otherwise protected by law. The information is solely 
intended for the named addressee (or a person responsible for delivering it to 
the addressee). If you are not the intended recipient of this message, you are 
not authorized to read, print, retain, copy or disseminate this message or any 
part of it. If you have received this e-mail in error, please notify the sender 
immediately by return e-mail and delete it from your computer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
