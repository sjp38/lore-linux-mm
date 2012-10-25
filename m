Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id D97F76B0062
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 05:53:21 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so2466308ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 02:53:21 -0700 (PDT)
Message-ID: <50890C06.5060305@gmail.com>
Date: Thu, 25 Oct 2012 17:53:10 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <5088C51D.3060009@gmail.com> <alpine.LNX.2.00.1210242338030.2688@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1210242338030.2688@eggly.anvils>
Content-Type: multipart/alternative;
 boundary="------------090709030502040204030605"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This is a multi-part message in MIME format.
--------------090709030502040204030605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 10/25/2012 02:59 PM, Hugh Dickins wrote:
> On Thu, 25 Oct 2012, Ni zhan Chen wrote:
>> On 10/25/2012 12:36 PM, Hugh Dickins wrote:
>>> On Wed, 24 Oct 2012, Dave Jones wrote:
>>>
>>>> Machine under significant load (4gb memory used, swap usage fluctuating)
>>>> triggered this...
>>>>
>>>> WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
>>>> Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49
>>>>
>>>> 1148                         error = shmem_add_to_page_cache(page,
>>>> mapping, index,
>>>> 1149                                                 gfp,
>>>> swp_to_radix_entry(swap));
>>>> 1150                         /* We already confirmed swap, and make no
>>>> allocation */
>>>> 1151                         VM_BUG_ON(error);
>>>> 1152                 }
>>> That's very surprising.  Easy enough to handle an error there, but
>>> of course I made it a VM_BUG_ON because it violates my assumptions:
>>> I rather need to understand how this can be, and I've no idea.
>>>
>>> Clutching at straws, I expect this is entirely irrelevant, but:
>>> there isn't a warning on line 1151 of mm/shmem.c in 3.7.0-rc2 nor
>>> in current linux.git; rather, there's a VM_BUG_ON on line 1149.
>>>
>>> So you've inserted a couple of lines for some reason (more useful
>>> trinity behaviour, perhaps)?  And have some config option I'm
>>> unfamiliar with, that mutates a BUG_ON or VM_BUG_ON into a warning?
>> Hi Hugh,
>>
>> I think it maybe caused by your commit [d189922862e03ce: shmem: fix negative
>> rss in memcg memory.stat], one question:
> Well, yes, I added the VM_BUG_ON in that commit.
>
>> if function shmem_confirm_swap confirm the entry has already brought back
>> from swap by a racing thread,
> The reverse: true confirms that the swap entry has not been brought back
> from swap by a racing thread; false indicates that there has been a race.
>
>> then why call shmem_add_to_page_cache to add
>> page from swapcache to pagecache again?
> Adding it to pagecache again, after such a race, would set error to
> -EEXIST (originating from radix_tree_insert); but we don't do that,
> we add it to pagecache when it has not already been added.
>
> Or that's the intention: but Dave seems to have found an unexpected
> exception, despite us holding the page lock across all this.
>
> (But if it weren't for the memcg and replace_page issues, I'd much
> prefer to let shmem_add_to_page_cache discover the race as before.)
>
> Hugh

Hi Hugh

Thanks for your response. You mean the -EEXIST originating from 
radix_tree_insert, in radix_tree_insert:
if (slot != NULL)
     return -EEXIST;
But why slot should be NULL? if no race, the pagecache related radix 
tree entry should be RADIX_TREE_EXCEPTIONAL_ENTRY+swap_entry_t.val, 
where I miss?

Regards,
Chen

>
>> otherwise, will goto unlock and then go to repeat? where I miss?
>>
>> Regards,
>> Chen


--------------090709030502040204030605
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 10/25/2012 02:59 PM, Hugh Dickins
      wrote:<br>
    </div>
    <blockquote
      cite="mid:alpine.LNX.2.00.1210242338030.2688@eggly.anvils"
      type="cite">
      <pre wrap="">On Thu, 25 Oct 2012, Ni zhan Chen wrote:
</pre>
      <blockquote type="cite">
        <pre wrap="">On 10/25/2012 12:36 PM, Hugh Dickins wrote:
</pre>
        <blockquote type="cite">
          <pre wrap="">On Wed, 24 Oct 2012, Dave Jones wrote:

</pre>
          <blockquote type="cite">
            <pre wrap="">Machine under significant load (4gb memory used, swap usage fluctuating)
triggered this...

WARNING: at mm/shmem.c:1151 shmem_getpage_gfp+0xa5c/0xa70()
Pid: 29795, comm: trinity-child4 Not tainted 3.7.0-rc2+ #49

1148                         error = shmem_add_to_page_cache(page,
mapping, index,
1149                                                 gfp,
swp_to_radix_entry(swap));
1150                         /* We already confirmed swap, and make no
allocation */
1151                         VM_BUG_ON(error);
1152                 }
</pre>
          </blockquote>
          <pre wrap="">That's very surprising.  Easy enough to handle an error there, but
of course I made it a VM_BUG_ON because it violates my assumptions:
I rather need to understand how this can be, and I've no idea.

Clutching at straws, I expect this is entirely irrelevant, but:
there isn't a warning on line 1151 of mm/shmem.c in 3.7.0-rc2 nor
in current linux.git; rather, there's a VM_BUG_ON on line 1149.

So you've inserted a couple of lines for some reason (more useful
trinity behaviour, perhaps)?  And have some config option I'm
unfamiliar with, that mutates a BUG_ON or VM_BUG_ON into a warning?
</pre>
        </blockquote>
        <pre wrap="">
Hi Hugh,

I think it maybe caused by your commit [d189922862e03ce: shmem: fix negative
rss in memcg memory.stat], one question:
</pre>
      </blockquote>
      <pre wrap="">
Well, yes, I added the VM_BUG_ON in that commit.

</pre>
      <blockquote type="cite">
        <pre wrap="">
if function shmem_confirm_swap confirm the entry has already brought back
from swap by a racing thread,
</pre>
      </blockquote>
      <pre wrap="">
The reverse: true confirms that the swap entry has not been brought back
from swap by a racing thread; false indicates that there has been a race.

</pre>
      <blockquote type="cite">
        <pre wrap="">then why call shmem_add_to_page_cache to add
page from swapcache to pagecache again?
</pre>
      </blockquote>
      <pre wrap="">
Adding it to pagecache again, after such a race, would set error to
-EEXIST (originating from radix_tree_insert); but we don't do that,
we add it to pagecache when it has not already been added.

Or that's the intention: but Dave seems to have found an unexpected
exception, despite us holding the page lock across all this.

(But if it weren't for the memcg and replace_page issues, I'd much
prefer to let shmem_add_to_page_cache discover the race as before.)

Hugh</pre>
    </blockquote>
    <br>
    Hi Hugh<br>
    <br>
    Thanks for your response. You mean the -EEXIST originating from
    radix_tree_insert, in radix_tree_insert:<br>
    if (slot != NULL)<br>
    &nbsp;&nbsp;&nbsp; return -EEXIST;<br>
    But why slot should be NULL? if no race, the pagecache related radix
    tree entry should be
    <meta http-equiv="content-type" content="text/html;
      charset=ISO-8859-1">
    <span style="color: rgb(0, 0, 0); font-family: song, Verdana;
      font-size: 14px; font-style: normal; font-variant: normal;
      font-weight: normal; letter-spacing: normal; line-height: 22px;
      orphans: 2; text-align: -webkit-auto; text-indent: 0px;
      text-transform: none; white-space: normal; widows: 2;
      word-spacing: 0px; -webkit-text-size-adjust: auto;
      -webkit-text-stroke-width: 0px; background-color: rgb(255, 255,
      255); display: inline !important; float: none; ">RADIX_TREE_EXCEPTIONAL_ENTRY+swap_entry_t.val,
      where I miss?<br>
      <br>
      Regards,<br>
      Chen<br>
    </span><br>
    <blockquote
      cite="mid:alpine.LNX.2.00.1210242338030.2688@eggly.anvils"
      type="cite">
      <pre wrap="">

</pre>
      <blockquote type="cite">
        <pre wrap="">otherwise, will goto unlock and then go to repeat? where I miss?

Regards,
Chen
</pre>
      </blockquote>
      <pre wrap="">
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------090709030502040204030605--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
