Message-ID: <40C61DA2.2080308@ammasso.com>
Date: Tue, 08 Jun 2004 14:12:18 -0600
From: Timur Tabi <timur.tabi@ammasso.com>
MIME-Version: 1.0
Subject: Do I need SetPageReserved() after map_user_kiobuf()? (was: What happened
 to try_to_swap_out()?)
References: <Pine.LNX.4.44.0406081224590.23676-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0406081224590.23676-100000@chimarrao.boston.redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> Looks like the bug is in your driver, not the VM.
> 
> The VMA that maps such pages should be set VM_RESERVED
> (or whatever the name of that flag was)

Ok, I've examined our code further and discovered a few things.

The previous developer apparently realized that the pages need to be 
marked reserved after a call to map_user_kiobuf().  However, his 
comments indicate that this is a work-around for the "kiobuf bug".  Am I 
to assume that you don't consider this a bug in map_user_kiobuf()?

This is the code that we run after map_user_kiobuf().

     int i;
     for (i = 0; i < kiobuf->nr_pages; i++)
         SetPageReserved(kiobuf->maplist[i]);

Also, since we're porting to 2.6, we're going to replace 
map_user_kiobuf() with get_user_pages().  Will we still need to call 
SetPageReserved()?  Unfortunately, I don't have a good enough 
understanding of the Linux VM to know exactly what get_user_pages() is 
doing.  For example, this code confuses me:

                 if (!PageReserved(pages[i]))
                     page_cache_get(pages[i]);

Under what circumstances would the pages already be reserved?

-- 
Timur Tabi
Staff Software Engineer
timur.tabi@ammasso.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
