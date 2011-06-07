Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5EF896B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 14:22:57 -0400 (EDT)
Received: by pzk4 with SMTP id 4so3321840pzk.14
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 11:22:54 -0700 (PDT)
Subject: Re: [PATCH] mm: Fix assertion mapping->nrpages == 0 in end_writeback()
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: multipart/alternative; boundary=Apple-Mail-1-598770631
From: Jinshan Xiong <jinshan.xiong@whamcloud.com>
In-Reply-To: <1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
Date: Tue, 7 Jun 2011 11:22:48 -0700
Message-Id: <24671813-6F79-4746-8BF1-7CC50F4BBBCA@whamcloud.com>
References: <1306748258-4732-1-git-send-email-jack@suse.cz> <20110606151614.0037e236.akpm@linux-foundation.org> <1307425597.3649.61.camel@tucsk.pomaz.szeredi.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <mszeredi@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, stable@kernel.org, Nick Piggin <npiggin@kernel.dk>


--Apple-Mail-1-598770631
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii


On Jun 6, 2011, at 10:46 PM, Miklos Szeredi wrote:

> On Mon, 2011-06-06 at 15:16 -0700, Andrew Morton wrote:
>> On Mon, 30 May 2011 11:37:38 +0200
>> Jan Kara <jack@suse.cz> wrote:
>>=20
>>> Under heavy memory and filesystem load, users observe the assertion
>>> mapping->nrpages =3D=3D 0 in end_writeback() trigger. This can be =
caused
>>> by page reclaim reclaiming the last page from a mapping in the =
following
>>> race:
>>> 	CPU0				CPU1
>>>  ...
>>>  shrink_page_list()
>>>    __remove_mapping()
>>>      __delete_from_page_cache()
>>>        radix_tree_delete()
>>> 					evict_inode()
>>> 					  truncate_inode_pages()
>>> 					    truncate_inode_pages_range()
>>> 					      pagevec_lookup() - finds =
nothing
>>> 					  end_writeback()
>>> 					    mapping->nrpages !=3D 0 -> =
BUG
>>>        page->mapping =3D NULL
>>>        mapping->nrpages--
>>>=20
>>> Fix the problem by cycling the mapping->tree_lock at the end of
>>> truncate_inode_pages_range() to synchronize with page reclaim.
>>>=20
>>> Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
>>> out by Miklos Szeredi <mszeredi@suse.de>.
>>>=20
>>> CC: Jay <jinshan.xiong@whamcloud.com>
>>> CC: stable@kernel.org
>>> Acked-by: Miklos Szeredi <mszeredi@suse.de>
>>> Signed-off-by: Jan Kara <jack@suse.cz>
>>> ---
>>> mm/truncate.c |    7 +++++++
>>> 1 files changed, 7 insertions(+), 0 deletions(-)
>>>=20
>>> Andrew, would you merge this patch please? Thanks.
>>>=20
>>> diff --git a/mm/truncate.c b/mm/truncate.c
>>> index a956675..ec3d292 100644
>>> --- a/mm/truncate.c
>>> +++ b/mm/truncate.c
>>> @@ -291,6 +291,13 @@ void truncate_inode_pages_range(struct =
address_space *mapping,
>>> 		pagevec_release(&pvec);
>>> 		mem_cgroup_uncharge_end();
>>> 	}
>>> +	/*
>>> +	 * Cycle the tree_lock to make sure all =
__delete_from_page_cache()
>>> +	 * calls run from page reclaim have finished as well (this =
handles the
>>> +	 * case when page reclaim took the last page from our range).
>>> +	 */
>>> +	spin_lock_irq(&mapping->tree_lock);
>>> +	spin_unlock_irq(&mapping->tree_lock);
>>> }
>>> EXPORT_SYMBOL(truncate_inode_pages_range);
>>=20
>> That's one ugly patch.
>>=20
>>=20
>> Perhaps this regression was added by Nick's RCUification of =
pagecache.=20
>>=20
>> Before that patch, mapping->nrpages and the radix-tree state were
>> coherent for holders of tree_lock.  So pagevec_lookup() would never
>> return "no pages" while ->nrpages is non-zero.
>>=20
>> After that patch, find_get_pages() uses RCU to protect the radix-tree
>> but I don't think it correctly protects the aggregate (radix-tree +
>> nrpages).
>=20
> Yes, that's the case.
>=20
>>=20
>>=20
>> If it's not that then I see another possibility.=20
>> truncate_inode_pages_range() does
>>=20
>>        if (mapping->nrpages =3D=3D 0)
>>                return;
>>=20
>> Is there anything to prevent a page getting added to the inode =
_after_
>> this test?  i_mutex?  If not, that would trigger the BUG.
>=20
> That BUG is in the inode eviction phase, so there's nothing that could
> be adding a page.
>=20
> And the only thing that could be removing one is page reclaim.
>=20
>> Either way, I don't think that the uglypatch expresses a full
>> understanding of te bug ;)
>=20
> I don't see a better way, how would we make nrpages update atomically
> wrt the radix-tree while using only RCU?
>=20
> The question is, does it matter that those two can get temporarily out
> of sync?
>=20
> In case of inode eviction it does, not only because of that BUG_ON, =
but
> because page reclaim must be somehow synchronised with eviction.
> Otherwise it may access tree_lock on the mapping of an already freed
> inode.

I tend to think your patch is absolutely ok to fix this problem. =
However, I think it would be better to move:

spin_lock(&mapping->tree_lock);
spin_unlock(&mapping->tree_lock);

into end_writeback(). This is because truncate_inode_pages_range() is a =
generic function and it will be called somewhere else, maybe =
unnecessarily to do this extra thing.

Actually, I'd like to hold an inode refcount in page stealing process. =
The reason is obvious: it makes no sense to steal pages from a =
to-be-freed inode. However, the problem is the overhead to grab an inode =
is damned heavy.

Thanks,
Jinshan

>=20
> In other cases?  AFAICS it doesn't matter.  Most ->nrpages accesses
> weren't under tree_lock before Nick's RCUification, so their use were
> just optimization.  =20
>=20
> Thanks,
> Miklos
>=20
>=20


--Apple-Mail-1-598770631
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=us-ascii

<html><head></head><body style=3D"word-wrap: break-word; =
-webkit-nbsp-mode: space; -webkit-line-break: after-white-space; =
"><br><div><div>On Jun 6, 2011, at 10:46 PM, Miklos Szeredi =
wrote:</div><br class=3D"Apple-interchange-newline"><blockquote =
type=3D"cite"><div>On Mon, 2011-06-06 at 15:16 -0700, Andrew Morton =
wrote:<br><blockquote type=3D"cite">On Mon, 30 May 2011 11:37:38 =
+0200<br></blockquote><blockquote type=3D"cite">Jan Kara &lt;<a =
href=3D"mailto:jack@suse.cz">jack@suse.cz</a>&gt; =
wrote:<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">Under heavy memory and filesystem load, users observe the =
assertion<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">mapping-&gt;nrpages =3D=3D 0 in =
end_writeback() trigger. This can be =
caused<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">by page reclaim reclaiming the last page from a mapping in =
the following<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote =
type=3D"cite">race:<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span>CPU0<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>CPU1<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> =
&nbsp;...<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> =
&nbsp;shrink_page_list()<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;__remove_mapping()<br></blockquote></blockquote><blockqu=
ote type=3D"cite"><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;__delete_from_page_cache()<br></blockquote><=
/blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;radix_tree_delete()<br></blockqu=
ote></blockquote><blockquote type=3D"cite"><blockquote type=3D"cite"><span=
 class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>evict_inode()<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> =
&nbsp;truncate_inode_pages()<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> =
&nbsp;&nbsp;&nbsp;truncate_inode_pages_range()<br></blockquote></blockquot=
e><blockquote type=3D"cite"><blockquote type=3D"cite"><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span><span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	</span> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pagevec_lookup() - finds =
nothing<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote=
 type=3D"cite"><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span><span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> &nbsp;end_writeback()<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> =
&nbsp;&nbsp;&nbsp;mapping-&gt;nrpages !=3D 0 -&gt; =
BUG<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page-&gt;mapping =3D =
NULL<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;mapping-&gt;nrpages--<br></block=
quote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">Fix the problem by cycling the =
mapping-&gt;tree_lock at the end =
of<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">truncate_inode_pages_range() to synchronize with page =
reclaim.<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">Analyzed by Jay &lt;<a =
href=3D"mailto:jinshan.xiong@whamcloud.com">jinshan.xiong@whamcloud.com</a=
>&gt;, lost in LKML, and dug<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">out by Miklos Szeredi &lt;<a =
href=3D"mailto:mszeredi@suse.de">mszeredi@suse.de</a>&gt;.<br></blockquote=
></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">CC: Jay &lt;<a =
href=3D"mailto:jinshan.xiong@whamcloud.com">jinshan.xiong@whamcloud.com</a=
>&gt;<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">CC: <a =
href=3D"mailto:stable@kernel.org">stable@kernel.org</a><br></blockquote></=
blockquote><blockquote type=3D"cite"><blockquote type=3D"cite">Acked-by: =
Miklos Szeredi &lt;<a =
href=3D"mailto:mszeredi@suse.de">mszeredi@suse.de</a>&gt;<br></blockquote>=
</blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">Signed-off-by: Jan Kara &lt;<a =
href=3D"mailto:jack@suse.cz">jack@suse.cz</a>&gt;<br></blockquote></blockq=
uote><blockquote type=3D"cite"><blockquote =
type=3D"cite">---<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> mm/truncate.c | =
&nbsp;&nbsp;&nbsp;7 +++++++<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> 1 files changed, 7 =
insertions(+), 0 deletions(-)<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> Andrew, would you merge this =
patch please? Thanks.<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote =
type=3D"cite"><br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">diff --git a/mm/truncate.c =
b/mm/truncate.c<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">index a956675..ec3d292 =
100644<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">--- =
a/mm/truncate.c<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">+++ =
b/mm/truncate.c<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">@@ -291,6 +291,13 @@ void =
truncate_inode_pages_range(struct address_space =
*mapping,<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite"> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>pagevec_release(&amp;pvec);<br></blockquote></blockquote><blockquot=
e type=3D"cite"><blockquote type=3D"cite"> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span><span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>mem_cgroup_uncharge_end();<br></blockquote></blockquote><blockquote=
 type=3D"cite"><blockquote type=3D"cite"> <span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>}<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>/*<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> * Cycle the tree_lock to make =
sure all =
__delete_from_page_cache()<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	</span> * calls run from page reclaim =
have finished as well (this handles =
the<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> * case when page reclaim took the last page from our =
range).<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote=
 type=3D"cite">+<span class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span> */<br></blockquote></blockquote><blockquote =
type=3D"cite"><blockquote type=3D"cite">+<span class=3D"Apple-tab-span" =
style=3D"white-space:pre">	=
</span>spin_lock_irq(&amp;mapping-&gt;tree_lock);<br></blockquote></blockq=
uote><blockquote type=3D"cite"><blockquote type=3D"cite">+<span =
class=3D"Apple-tab-span" style=3D"white-space:pre">	=
</span>spin_unlock_irq(&amp;mapping-&gt;tree_lock);<br></blockquote></bloc=
kquote><blockquote type=3D"cite"><blockquote type=3D"cite"> =
}<br></blockquote></blockquote><blockquote type=3D"cite"><blockquote =
type=3D"cite"> =
EXPORT_SYMBOL(truncate_inode_pages_range);<br></blockquote></blockquote><b=
lockquote type=3D"cite"><br></blockquote><blockquote type=3D"cite">That's =
one ugly patch.<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite">Perhaps this =
regression was added by Nick's RCUification of pagecache. =
<br></blockquote><blockquote type=3D"cite"><br></blockquote><blockquote =
type=3D"cite">Before that patch, mapping-&gt;nrpages and the radix-tree =
state were<br></blockquote><blockquote type=3D"cite">coherent for =
holders of tree_lock. &nbsp;So pagevec_lookup() would =
never<br></blockquote><blockquote type=3D"cite">return "no pages" while =
-&gt;nrpages is non-zero.<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite">After that =
patch, find_get_pages() uses RCU to protect the =
radix-tree<br></blockquote><blockquote type=3D"cite">but I don't think =
it correctly protects the aggregate (radix-tree =
+<br></blockquote><blockquote =
type=3D"cite">nrpages).<br></blockquote><br>Yes, that's the =
case.<br><br><blockquote type=3D"cite"><br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite">If it's not =
that then I see another possibility. <br></blockquote><blockquote =
type=3D"cite">truncate_inode_pages_range() =
does<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (mapping-&gt;nrpages =3D=3D =
0)<br></blockquote><blockquote type=3D"cite"> =
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;return;<br></blockquote><blockquote =
type=3D"cite"><br></blockquote><blockquote type=3D"cite">Is there =
anything to prevent a page getting added to the inode =
_after_<br></blockquote><blockquote type=3D"cite">this test? =
&nbsp;i_mutex? &nbsp;If not, that would trigger the =
BUG.<br></blockquote><br>That BUG is in the inode eviction phase, so =
there's nothing that could<br>be adding a page.<br><br>And the only =
thing that could be removing one is page reclaim.<br><br><blockquote =
type=3D"cite">Either way, I don't think that the uglypatch expresses a =
full<br></blockquote><blockquote type=3D"cite">understanding of te bug =
;)<br></blockquote><br>I don't see a better way, how would we make =
nrpages update atomically<br>wrt the radix-tree while using only =
RCU?<br><br>The question is, does it matter that those two can get =
temporarily out<br>of sync?<br><br>In case of inode eviction it does, =
not only because of that BUG_ON, but<br>because page reclaim must be =
somehow synchronised with eviction.<br>Otherwise it may access tree_lock =
on the mapping of an already =
freed<br>inode.<br></div></blockquote><div><br></div><div>I tend to =
think your patch is absolutely ok to fix this problem. However, I think =
it would be better to =
move:</div><div><br></div><div>spin_lock(&amp;mapping-&gt;tree_lock);</div=
><div>spin_unlock(&amp;mapping-&gt;tree_lock);</div><div><br></div><div>in=
to end_writeback(). This is because&nbsp;truncate_inode_pages_range() is =
a generic function and it will be called somewhere else, maybe =
unnecessarily to do this extra thing.</div><div><br></div><div>Actually, =
I'd like to hold an inode refcount in page stealing process. The reason =
is obvious: it makes no sense to steal pages from a to-be-freed inode. =
However, the problem is the overhead to grab an inode is damned =
heavy.</div><div><br></div><div>Thanks,</div><div>Jinshan</div><br><blockq=
uote type=3D"cite"><div><br>In other cases? &nbsp;AFAICS it doesn't =
matter. &nbsp;Most -&gt;nrpages accesses<br>weren't under tree_lock =
before Nick's RCUification, so their use were<br>just optimization. =
&nbsp;&nbsp;<br><br>Thanks,<br>Miklos<br><br><br></div></blockquote></div>=
<br></body></html>=

--Apple-Mail-1-598770631--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
