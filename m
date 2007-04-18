Message-ID: <46259945.8040504@google.com>
Date: Tue, 17 Apr 2007 21:06:29 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: meminfo returns inaccurate NR_FILE_PAGES
References: <46255446.6060204@google.com> <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704171655390.9381@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 17 Apr 2007, Ethan Solomita wrote:
>
>   
>>      Note that File Pages is 62040kB when MemUsed is only 4824kB. We do
>> __(dec|inc)_zone_page_state(page, NR_FILE_PAGES) whenever doing a
>> radix_tree_(delete|insert) from/to mapping->page_tree. Except we missed one:
>>     
>
> Right. Sigh. Does this fix it?
>
> Fix NR_FILE_PAGES and NR_ANON_PAGES accounting.
>   

    I don't think that there's a problem with NR_ANON_PAGES. 
unmap_and_move(), the caller of move_to_new_page(), calls try_to_unmap() 
which calls try_to_unmap_anon() which calls try_to_unmap_one() which 
calls page_remove_rmap() which in turn makes the call to 
__dec_zone_page_state. i.e. the rmap() code is handling NR_ANON_PAGES 
and NR_FILE_MAPPED pages correctly. It's just the NR_FILE_PAGES which 
are tied to the mapping's page tree, where the problem lies.
    -- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
