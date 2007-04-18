Message-ID: <4625AD3C.8010709@google.com>
Date: Tue, 17 Apr 2007 22:31:40 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com> <46259945.8040504@google.com> <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704172157470.3003@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>> It's just the NR_FILE_PAGES which are tied to the mapping's page tree, where
>> the problem lies.
>>     
>
> Ah. I see.
>
> However, anonymous pages may also have a mapping (swap). So we need to 
> check first that it is not an anonymous page and then eventually shift 
> the count between zones.
>   

    Anonymous pages have a value in mapping, but it's not a struct 
address_space, it's a struct vm_area_struct (+1). The NR_FILE_PAGES 
count is incremented and decremented only when something is added to or 
removed from an address_space's page_table as pointed to by a mapping. 
This is only done in filemap.c, except for this one example in migrate.c 
that changes the radix table's page pointer in place. I think that all 
that is needed is an extra set of lines in migrate_page_move_mapping() 
after modifying *radix_pointer to call __dec on the old page and __inc 
on the new. You can check the zones first if you'd like to save effort, 
although I'm not sure it's a big deal since the __dec and __inc 
functions are only modifying per-cpu accumulation variables.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
