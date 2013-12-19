Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id CF0C36B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 15:25:34 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so1558796qeb.34
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:25:34 -0800 (PST)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id f4si1710489qcs.77.2013.12.19.12.25.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 12:25:33 -0800 (PST)
Received: by mail-ve0-f169.google.com with SMTP id c14so995483vea.14
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:25:33 -0800 (PST)
MIME-Version: 1.0
Reply-To: matvejchikov@gmail.com
From: Matvejchikov Ilya <matvejchikov@gmail.com>
Date: Fri, 20 Dec 2013 00:25:13 +0400
Message-ID: <CAKh5naYHUUUPnSv4skmX=+88AB-L=M4ruQti5cX=1BRxZY2JRg@mail.gmail.com>
Subject: A question aboout virtual mapping of kernel and module pages
Content-Type: multipart/alternative; boundary=047d7b677208a6662d04ede8f615
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ilya Matveychikov <matvejchikov@gmail.com>

--047d7b677208a6662d04ede8f615
Content-Type: text/plain; charset=ISO-8859-1

I'm using VMAP function to create memory writable mapping as it suggested
in ksplice project. Here is the implementation of map_writable function:

/*
 * map_writable creates a shadow page mapping of the range
 * [addr, addr + len) so that we can write to code mapped read-only.
 *
 * It is similar to a generalized version of x86's text_poke.  But
 * because one cannot use vmalloc/vfree() inside stop_machine, we use
 * map_writable to map the pages before stop_machine, then use the
 * mapping inside stop_machine, and unmap the pages afterwards.
 */
static void *map_writable(void *addr, size_t len)
{
        void *vaddr;
        int nr_pages = DIV_ROUND_UP(offset_in_page(addr) + len, PAGE_SIZE);
        struct page **pages = kmalloc(nr_pages * sizeof(*pages),
GFP_KERNEL);
        void *page_addr = (void *)((unsigned long)addr & PAGE_MASK);
        int i;

        if (pages == NULL)
                return NULL;

        for (i = 0; i < nr_pages; i++) {
                if (__module_address((unsigned long)page_addr) == NULL) {
                        pages[i] = virt_to_page(page_addr);
                        WARN_ON(!PageReserved(pages[i]));
                } else {
                        pages[i] = vmalloc_to_page(page_addr);
                }
                if (pages[i] == NULL) {
                        kfree(pages);
                        return NULL;
                }
                page_addr += PAGE_SIZE;
        }
        vaddr = vmap(pages, nr_pages, VM_MAP, PAGE_KERNEL);
        kfree(pages);
        if (vaddr == NULL)
                return NULL;
        return vaddr + offset_in_page(addr);
}

This function works well when I used it to map kernel's text addresses. All
fine and I can rewrite read-only data well via the mapping.

Now, I need to modify kernel module's text. Given the symbol address inside
the module, I use the same method. The mapping I've got seems to be valid.
But all my changes visible only in that mapping and not in the module!

I suppose that in case of module mapping I get something like copy-on-write
but I can't prove it.

Can anyone explain me what's happend and why I can use it for mapping
kernel and can't for modules?

http://stackoverflow.com/questions/20658357/virtual-mapping-of-kernel-and-module-pages

--047d7b677208a6662d04ede8f615
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I&#39;m using VMAP function to create memory writable mapp=
ing as it suggested in ksplice project. Here is the implementation of map_w=
ritable function:<br><br>/*<br>=A0* map_writable creates a shadow page mapp=
ing of the range<br>

=A0* [addr, addr + len) so that we can write to code mapped read-only.<br>=
=A0*<br>=A0* It is similar to a generalized version of x86&#39;s text_poke.=
 =A0But<br>=A0* because one cannot use vmalloc/vfree() inside stop_machine,=
 we use<br>

=A0* map_writable to map the pages before stop_machine, then use the<br>=A0=
* mapping inside stop_machine, and unmap the pages afterwards.<br>=A0*/<br>=
static void *map_writable(void *addr, size_t len)<br>{<br>=A0 =A0 =A0 =A0 v=
oid *vaddr;<br>

=A0 =A0 =A0 =A0 int nr_pages =3D DIV_ROUND_UP(offset_in_page(addr) + len, P=
AGE_SIZE);<br>=A0 =A0 =A0 =A0 struct page **pages =3D kmalloc(nr_pages * si=
zeof(*pages), GFP_KERNEL);<br>=A0 =A0 =A0 =A0 void *page_addr =3D (void *)(=
(unsigned long)addr &amp; PAGE_MASK);<br>

=A0 =A0 =A0 =A0 int i;<br><br>=A0 =A0 =A0 =A0 if (pages =3D=3D NULL)<br>=A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br><br>=A0 =A0 =A0 =A0 for (i =3D=
 0; i &lt; nr_pages; i++) {<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (__module=
_address((unsigned long)page_addr) =3D=3D NULL) {<br>=A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D virt_to_page(page_addr);<br>

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON(!PageReserved(pages=
[i]));<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {<br>=A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 pages[i] =3D vmalloc_to_page(page_addr);<br>=A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pages=
[i] =3D=3D NULL) {<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree=
(pages);<br>

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>=A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 }<br>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_addr +=3D PA=
GE_SIZE;<br>=A0 =A0 =A0 =A0 }<br>=A0 =A0 =A0 =A0 vaddr =3D vmap(pages, nr_p=
ages, VM_MAP, PAGE_KERNEL);<br>=A0 =A0 =A0 =A0 kfree(pages);<br>=A0 =A0 =A0=
 =A0 if (vaddr =3D=3D NULL)<br>

=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;<br>=A0 =A0 =A0 =A0 return vadd=
r + offset_in_page(addr);<br>}<br><br>This function works well when I used =
it to map kernel&#39;s text addresses. All fine and I can rewrite read-only=
 data well via the mapping.<br>

<br>Now, I need to modify kernel module&#39;s text. Given the symbol addres=
s inside the module, I use the same method. The mapping I&#39;ve got seems =
to be valid. But all my changes visible only in that mapping and not in the=
 module!<br>

<br>I suppose that in case of module mapping I get something like copy-on-w=
rite but I can&#39;t prove it.<br><br>Can anyone explain me what&#39;s happ=
end and why I can use it for mapping kernel and can&#39;t for modules?<br>

<br><a href=3D"http://stackoverflow.com/questions/20658357/virtual-mapping-=
of-kernel-and-module-pages">http://stackoverflow.com/questions/20658357/vir=
tual-mapping-of-kernel-and-module-pages</a></div>

--047d7b677208a6662d04ede8f615--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
